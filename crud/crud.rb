# 20/03/2025
# Mi segundo programa en Ruby :D

require 'json'
archivo = "database.json"

# Función para guardar datos en el archivo JSON
# Para no tener que re-escribir esta parte en cada función que modifique el archivo
def guardar_datos(archivo, datos)
  File.open(archivo, "w") do |f|
    f.write(JSON.pretty_generate(datos))
  end
end

# Antes de agregar nuevos datos, se debe verificar si el archivo JSON ya contiene datos.
# De lo contrario, se reescribirá lo previamente guardado cada vez que se ingresan nuevos datos.
if File.exist?(archivo)
  contenido = File.read(archivo)
  datos = JSON.parse(contenido) rescue []
else
  datos = []
end

puts "¡Bienvenido!"

loop do 
puts "¿Qué desea hacer?"
puts "1. Ingresar nuevos datos"
puts "2. Ver datos guardados"
puts "3. Modificar datos"
puts "4. Eliminar datos"
puts "5. Salir del programa"
opcion = gets.chomp.to_i

case opcion
when 1
  puts "Ingrese su nombre:"
  nombre = gets.chomp
  puts "Ingrese su edad:"
  edad = gets.chomp.to_i
  
  # Obtener el último ID registrado para luego asignar uno nuevo
  # Cada entrada debe tener su propio ID, de lo contrario es más difícil modificar o eliminar entradas
  ultimo_id = datos.empty? ? 1 : datos.last["id"] + 1

  datos << { "id" => ultimo_id, "nombre" => nombre, "edad" => edad }

  guardar_datos(archivo, datos)
  
  puts "¡Datos guardados con éxito!"

when 2
  if datos.empty?
    puts "Lo siento, no hay datos guardados."
  else
    puts "Lista de datos guardados:"
    datos.each do |persona|
      puts "ID: #{persona["id"]} - Nombre: #{persona["nombre"]}, Edad: #{persona["edad"]}"
    end
  end

when 3
  if datos.empty?
    puts "Lo siento, no puede realizar esta acción porque no hay datos guardados."
  else
    puts "Lista de datos guardados:"
    datos.each do |persona|
      puts "ID: #{persona["id"]} - Nombre: #{persona["nombre"]}, Edad: #{persona["edad"]}"
    end

    puts "Ingrese el ID de la persona que desea modificar:"
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

      guardar_datos(archivo, datos)

      puts "¡Datos modificados con éxito!"

    else
      puts "ID no encontrado."
    end
  end

when 4
  if datos.empty?
    puts "Lo siento, no puede realizar esta acción porque no hay datos guardados."
  else
    puts "Lista de datos guardados:"
    datos.each do |persona|
      puts "ID: #{persona["id"]} - Nombre: #{persona["nombre"]}, Edad: #{persona["edad"]}"
    end

    puts "Ingrese el ID de la persona que desea eliminar:"
    id_eliminar = gets.chomp.to_i

    # Filtrar los datos para eliminar el registro con el ID ingresado
    datos_filtrados = datos.reject { |p| p["id"] == id_eliminar }

    if datos_filtrados.size < datos.size
      guardar_datos(archivo, datos_filtrados)
      puts "¡Datos eliminados con éxito!"
    else
      puts "ID no encontrado."
    end
  end

when 5
  puts "¡Hasta la próxima!"
  break # Sale del loop y finaliza el programa.

else
  puts "Lo siento, no ingresaste una opción válida."
end
end

# Próximo objetivo:
# Reorganizar código en clases y objetos
# Validar ingreso de datos