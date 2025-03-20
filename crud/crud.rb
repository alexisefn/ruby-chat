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
puts "¿Qué desea hacer?"
puts "1. Ingresar nuevos datos"
puts "2. Ver datos guardados"
opcion = gets.chomp.to_i

if opcion == 1
  puts "Ingrese su nombre:"
  nombre = gets.chomp
  puts "Ingrese su edad:"
  edad = gets.chomp.to_i

  datos << { "nombre" => nombre, "edad" => edad }

  File.open(archivo, "w") do |f|
    f.write(JSON.pretty_generate(datos))
  end
  
  puts "¡Datos guardados con éxito!"

elsif opcion == 2
  if datos.empty?
    puts "No hay datos guardados."
  else
    puts "Lista de datos guardados:"
    datos.each_with_index do |persona, i|
      puts "#{i + 1}. Nombre: #{persona["nombre"]}, Edad: #{persona["edad"]}"
    end
  end
else
  puts "Lo siento, no ingresaste una opción válida."
end

puts "¡Hasta la próxima!"

# Este es un commit desde VS Code

# Próximo objetivo:
# Modificar y eliminar datos