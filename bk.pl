#!/usr/bin/perl

# Ejecutar perl bk.pl ip_maquina cod_cliente cod_maquina tipo_copia [auto o manual] usuario_ftp pass_ftp

use DBI;
use Net::SFTP::Foreign;

#Datos de la conexión 
$db="db_proyectint";
$host="datos.proyectint.org";
$port="3306";
$user="user_proyectint";
$pass="12Proyectint34*";
$connectionInfo="DBI:mysql:database=$db;$host:$port";

# Realizamos la conexión a la base de datos 
$db = DBI->connect($connectionInfo,$user,$pass);

# Cogemos fecha desde MySQL
$qu_date="select sysdate()";
$sql_date = $db->prepare($qu_date);
$sql_date->execute();
$date = $sql_date->fetchrow_array();

# Inserto primeros datos de la copia
$query="insert into copias (cod_cliente,cod_maquina,fecha_ini,tipo_copia) values ('@ARGV[1]','@ARGV[2]','$date','@ARGV[3]')";
$sql = $db->prepare($query);
$sql->execute();

# Llamada al script bash SOLUCIONAR!!
`bash bk.sh @ARGV[0] @ARGV[2] @ARGV[1]`;
$n=0;
open (re,"/root/temp") or die "$!n";
while (<re>){
	chomp;
	@result[$n]=$_;
	$n++;
}
close re;

# Actualizo datos de copia en BDD
if (@result[0] eq "OK"){
	$up="update copias set fecha_fin = sysdate(), correcta= 'si', nombre_fichero = '@result[1]' where fecha_ini = '$date'";

	# Subir a FTP el paquete
	$sftp = Net::SFTP::Foreign->new("datos.proyectint.org",user => "@ARGV[4]", password => "@ARGV[5]") or die("No se pudo conectar al servidor: $!");
	$sftp->put('/root/bk/'.@ARGV[1].'/'.@ARGV[2].'/'.@result[1]) or die "$!n";

	# Elimino paquete
	`rm /root/bk/@ARGV[1]/@ARGV[2]/@result[1]`;
	print "Copia de seguridad realizada con exito\n";
}else{
	$up="update copias set fecha_fin = sysdate(), correcta= 'no' where fecha_ini = '&date'";
	print "Copia de seguridad no realizada\n";
}

$sql2 = $db->prepare($up);
$sql2->execute();
$sql_date->finish();

$sql2->finish();
$db->disconnect;

`rm /root/temp`;
