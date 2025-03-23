# 20/03/2025
# Mi segundo programa en Ruby :D

require 'json'

class Persona
  attr_accessor :id, :nombre, :edad

  def initialize(id, nombre, edad)
    @id = id
    @nombre = nombre
    @edad = edad
  end

  def to_hash
    { "id" => @id, "nombre" => @nombre, "edad" => @edad }
  end
end

class GestorDatos
  def initialize(archivo)
    @archivo = archivo
    @datos = cargar_datos
  end

  # Antes de agregar nuevos datos, se debe verificar si el archivo JSON ya contiene datos.
  # De lo contrario, se reescribirá lo previamente guardado cada vez que se ingresan nuevos datos.
  def cargar_datos
    if File.exist?(@archivo)
      contenido = File.read(@archivo)
      JSON.parse(contenido) rescue []
    else
      []
    end
  end

  # Función para guardar datos en el archivo JSON
  # Para no tener que re-escribir esta parte en cada función que modifique el archivo
  def guardar_datos
    File.open(@archivo, "w") do |f|
      f.write(JSON.pretty_generate(@datos))
    end
  end

  # Funciones para validar el ingreso de datos
  # Ejemplo: Que nombre solo contenga letras, espacios, apóstrofes y guiones
  # O que edad solo contenga números
  def nombre_valido?(nombre)
    !!(nombre =~ /\A[a-zA-ZÁÉÍÓÚáéíóúñÑ\s'-]+\z/)
  end

  def edad_valida?(edad)
    edad.match?(/\A\d+\z/) && edad.to_i > 0
  end

  def agregar_persona
    nombre = ""
    edad = ""

    loop do
      puts "Ingrese su nombre:"
      nombre = gets.chomp
      break if nombre_valido?(nombre)
      puts "Nombre inválido. Solo se permiten letras, espacios, apóstrofes y guiones. Inténtelo de nuevo."
    end

    loop do
      puts "Ingrese su edad:"
      edad = gets.chomp
      break if edad_valida?(edad)
      puts "Edad inválida. Debe ser un número entero positivo. Inténtelo de nuevo."
    end

    # Obtener el último ID registrado para luego asignar uno nuevo
    # Cada entrada debe tener su propio ID, de lo contrario es más difícil modificar o eliminar entradas
    ultimo_id = @datos.empty? ? 1 : @datos.last["id"] + 1

    persona = Persona.new(ultimo_id, nombre, edad.to_i)
    @datos << persona.to_hash
    guardar_datos
    puts "¡Datos guardados con éxito!"
  end

  def listar_personas
    if @datos.empty?
      puts "Lo siento, no hay datos guardados."
    else
      puts "Lista de datos guardados:"
      @datos.each do |persona|
        puts "ID: #{persona["id"]} - Nombre: #{persona["nombre"]}, Edad: #{persona["edad"]}"
      end
    end
  end

  def modificar_persona
    if @datos.empty?
      puts "Lo siento, no puede realizar esta acción porque no hay datos guardados."
      return
    end

    listar_personas
    puts "Ingrese el ID de la persona que desea modificar:"
    id_modificar = gets.chomp.to_i
    # Busca el registro que coincida con el ID ingresado
    persona = @datos.find { |p| p["id"] == id_modificar }

    if persona
      puts "Ingrese los nuevos datos (deje vacío y presione Enter para no modificar)"
      puts "Nombre:"
      nuevo_nombre = gets.chomp
      puts "Edad:"
      nueva_edad = gets.chomp

      # Actualizar solo si el usaurio ingresó un nuevo valor
      # De lo contrario se saltará el proceso
      persona["nombre"] = nuevo_nombre unless nuevo_nombre.empty?
      persona["edad"] = nueva_edad.to_i unless nueva_edad.empty?
      
      guardar_datos
      puts "¡Datos modificados con éxito!"
    else
      puts "ID no encontrado."
    end
  end

  def eliminar_persona
    if @datos.empty?
      puts "Lo siento, no puede realizar esta acción porque no hay datos guardados."
      return
    end

    listar_personas
    puts "Ingrese el ID de la persona que desea eliminar:"
    id_eliminar = gets.chomp.to_i

    datos_filtrados = @datos.reject { |p| p["id"] == id_eliminar }

    if datos_filtrados.size < @datos.size
      @datos = datos_filtrados
      guardar_datos
      puts "¡Datos eliminados con éxito!"
    else
      puts "ID no encontrado."
    end
  end
end

# ------------------ FLUJO PRINCIPAL ------------------
archivo = "database.json"
gestor = GestorDatos.new(archivo)

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
    gestor.agregar_persona
  when 2
    gestor.listar_personas
  when 3
    gestor.modificar_persona
  when 4
    gestor.eliminar_persona
  when 5
    puts "¡Hasta la próxima!"
    break
  else
    puts "Lo siento, no ingresaste una opción válida."
  end
end