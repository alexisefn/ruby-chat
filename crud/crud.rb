# 20/03/2025
# Mi segundo programa en Ruby :D

require 'json'
archivo = "database.json"

# Antes de agregar nuevos datos, se debe verificar si el archivo JSON ya contiene datos.
# De lo contrario, se reescribirá lo previamente guardado cada vez que se ingresan nuevos datos.
if File.exist?(archivo)
  contenido = File.read(archivo)
  datos = JSON.parse(contenido) rescue []
else
  datos = []
end

puts "¡Hola!"
puts "Ingrese su nombre:"
nombre = gets.chomp
puts "Ingrese su edad:"
edad = gets.chomp.to_i

datos << { "nombre" => nombre, "edad" => edad }

File.open(archivo, "w") do |f|
  f.write(JSON.pretty_generate(datos))
end

puts "¡Datos guardados con éxito!"
puts "¡Hasta la próxima!"