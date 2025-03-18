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

# Función para modificar una persona
def modificar_persona
  personas = cargar_personas
  mostrar_personas

  print "Ingresa el ID de la persona a modificar: "
  id = gets.chomp.to_i

  persona = personas.find { |p| p.id == id }
  
  if persona
    puts "Modificando a #{persona.nombre}. Deja vacío para no cambiar el valor."

    print "Nuevo nombre (actual: #{persona.nombre}): "
    nuevo_nombre = gets.chomp
    persona.nombre = nuevo_nombre unless nuevo_nombre.empty?

    print "Nueva edad (actual: #{persona.edad}): "
    nueva_edad = gets.chomp
    persona.edad = nueva_edad.to_i if nueva_edad.match?(/^\d+$/)

    print "Nueva profesión (actual: #{persona.profesion}): "
    nueva_profesion = gets.chomp
    persona.profesion = nueva_profesion unless nueva_profesion.empty?

    puts "Nuevos pasatiempos (actuales: #{persona.pasatiempos.join(', ')})"
    puts "Ingresa uno por línea. Deja vacío para finalizar."
    nuevos_pasatiempos = []
    loop do
      entrada = gets.chomp
      break if entrada.empty?
      nuevos_pasatiempos << entrada
    end
    persona.pasatiempos = nuevos_pasatiempos unless nuevos_pasatiempos.empty?

    guardar_personas(personas)
    puts "¡Datos actualizados exitosamente!"
  else
    puts "No se encontró ninguna persona con ese ID."
  end
end

# Función para eliminar una persona
def eliminar_persona
  personas = cargar_personas
  mostrar_personas

  print "Ingresa el ID de la persona a eliminar: "
  id = gets.chomp.to_i

  persona = personas.find { |p| p.id == id }

  if persona
    print "¿Estás seguro de que deseas eliminar a #{persona.nombre}? (S/N): "
    confirmacion = gets.chomp.upcase
    if confirmacion == 'S'
      personas.reject! { |p| p.id == id }
      guardar_personas(personas)
      puts "Persona eliminada exitosamente."
    else
      puts "Operación cancelada."
    end
  else
    puts "No se encontró ninguna persona con ese ID."
  end
end

# Menú principal
loop do
  puts "¡Bienvenido!"
  puts "\nMenú Principal"
  puts "1) Agregar persona"
  puts "2) Mostrar personas registradas"
  puts "3) Modificar persona"
  puts "4) Eliminar persona"
  puts "5) Salir"
  print "Elige una opción: "
  
  opcion = gets.chomp

  case opcion
  when "1"
    agregar_persona
  when "2"
    mostrar_personas
  when "3"
    modificar_persona
  when "4"
    eliminar_persona
  when "5"
    puts "Saliendo del programa..."
    break
  else
    puts "Opción no válida. Inténtalo de nuevo."
  end
end