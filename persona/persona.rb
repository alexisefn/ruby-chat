require 'json'

# Definir clase
class Persona
  attr_accessor :id, :nombre, :edad, :profesion, :pasatiempos

  def initialize(id, nombre, edad, profesion, pasatiempos)
    @id = id
    @nombre = nombre
    @edad = edad.to_i
    @profesion = profesion
    @pasatiempos = pasatiempos
  end

  # Método para convertir datos en un hash (JSON)
  def to_h
    {
      id: @id,
      nombre: @nombre,
      edad: @edad,
      profesion: @profesion,
      pasatiempos: @pasatiempos
    }
  end
end

# Función para cargar datos desde archivo JSON
def cargar_personas
  if File.exist?('persona.json') && !File.empty?('persona.json')
    begin
      file = File.read('persona.json')
      datos = JSON.parse(file, symbolize_names: true)
      datos.map { |data| Persona.new(data[:id], data[:nombre], data[:edad], data[:profesion], data[:pasatiempos]) }
    rescue JSON::ParserError
      puts "Error: el archivo JSON está dañado. Se inicializará una lista vacía."
      []
    end
  else
    []
  end
end

# Función para guardar datos en un archivo en un archivo JSON
def guardar_personas(personas)
  File.open('persona.json', 'w') do |file|
    file.write(JSON.pretty_generate(personas.map(&:to_h)))
  end
end

# Función para ingresar nueva persona
def agregar_persona
  # Revisar primero el listado de personas para buscar la última entrada
  personas = cargar_personas
  # El índice será el tamaño actual del array + 1 para asegurar que sea acumulable
  indice = personas.empty? ? 1 : personas.last.id + 1

  print "Ingresa tu nombre: "
  nombre = gets.chomp
  print "Ingresa tu edad: "
  # Validar que la edad sea un número
  edad = nil
  loop do
    edad = gets.chomp
    if edad.match?(/^\d+$/)
      edad = edad.to_i
      break
    else
      print "Edad inválida. Ingresa un número válido: "
    end
  end
  print "Ingrese profesión: "
  profesion = gets.chomp
  puts "Ingresa tus pasatiempos (deja vació y presiona Enter para finalizar): "
  pasatiempos = []
  loop do
    entrada = gets.chomp
    break if entrada.empty?
    pasatiempos << entrada
  end

  # Crear persona
  nueva_persona = Persona.new(indice, nombre, edad, profesion, pasatiempos)
  personas << nueva_persona
  guardar_personas(personas)

  puts "¡Persona registrada exitosamente!"
end

# Función para mostrar todas las personas
def mostrar_personas
  personas = cargar_personas

  if personas.empty?
    puts "No hay personas registradas."
  else
    puts "\nLista de personas registradas:\n\n"
    personas.each do |persona|
      puts "Persona ##{persona.id}:"
      puts "Nombre: #{persona.nombre}"
      puts "Edad: #{persona.edad}"
      puts "Profesión: #{persona.profesion}"
      puts "Pasatiempos: #{persona.pasatiempos.join(', ')}"
      puts "-" * 30
    end
  end
end

# Menú principal
loop do
  puts "¡Bienvenido!"
  puts "\nMenú Principal"
  puts "1) Agregar persona"
  puts "2) Mostrar personas registradas"
  puts "3) Salir"
  print "Elige una opción: "
  
  opcion = gets.chomp

  case opcion
  when "1"
    agregar_persona
  when "2"
    mostrar_personas
  when "3"
    puts "Saliendo del programa..."
    break
  else
    puts "Opción no válida. Inténtalo de nuevo."
  end
end