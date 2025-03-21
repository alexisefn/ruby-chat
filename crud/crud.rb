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
puts "3. Modificar datos"
opcion = gets.chomp.to_i

if opcion == 1
  puts "Ingrese su nombre:"
  nombre = gets.chomp
  puts "Ingrese su edad:"
  edad = gets.chomp.to_i
  
  # Obtener el último ID registrado para luego asignar uno nuevo
  # Cada entrada debe tener su propio ID, de lo contrario es más difícil modificar o eliminar entradas
  ultimo_id = datos.empty? ? 1 : datos.last["id"] + 1

  datos << { "id" => ultimo_id, "nombre" => nombre, "edad" => edad }

  File.open(archivo, "w") do |f|
    f.write(JSON.pretty_generate(datos))
  end
  
  puts "¡Datos guardados con éxito!"

elsif opcion == 2
  if datos.empty?
    puts "Lo siento, no hay datos guardados."
  else
    puts "Lista de datos guardados:"
    datos.each do |persona|
      puts "ID: #{persona["id"]} - Nombre: #{persona["nombre"]}, Edad: #{persona["edad"]}"
    end
  end

elsif opcion == 3
  if datos.empty?
    puts "Lo siento, no puede realizar esta acción porque no hay datos guardados."
  else
    puts "Lista de datos guardados:"
    datos.each do |persona|
      puts "ID: #{persona["id"]} - Nombre: #{persona["nombre"]}, Edad: #{persona["edad"]}"
    end

    puts "Ingrese el ID  de la persona que desea modificar:"
    id_modificar = gets.chomp.to_i

    # Busca el registro que coincida con el ID ingresado
    persona = datos.find { |p| p["id"] == id_modificar }

    if persona
      puts "Ingrese los nuevos datos"
      puts "Deje vacio y presione Enter para no modificar"
      puts "Nombre: " # Sugerencia: Cambiar for print
      nuevo_nombre = gets.chomp
      puts "Edad: "
      nueva_edad = gets.chomp

      # Actualizar solo si el usaurio ingresó un nuevo valor
      # De lo contrario se saltará el proceso
      persona["nombre"] = nuevo_nombre unless nuevo_nombre.empty?
      persona["edad"] = nueva_edad.to_i unless nueva_edad.empty?

      File.open(archivo, "w") do |f|
        f.write(JSON.pretty_generate(datos))
      end

      puts "¡Datos modificados con éxito!"

    else
      puts "ID no encontrado"
    end
  end
else
  puts "Lo siento, no ingresaste una opción válida."
end

puts "¡Hasta la próxima!"

# Este es un commit desde VS Code

# Próximo objetivo:
# Modificar y eliminar datos