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

  # Generar nuevo ID único
  def self.generar_id(personas)
    ids_existentes = personas.map(&:id)
    (1..Float::INFINITY).find { |i| !ids_existentes.include?(i) }
  end
end

# Función para cargar datos desde archivo JSON
def cargar_personas
  return [] unless File.exist?('persona.json') && !File.empty?('persona.json')

  begin
    JSON.parse(File.read('persona.json'), symbolize_names: true)
    .map { |data| Persona.new(data[:id].to_i, data[:nombre], data[:edad], data[:profesion], data[:pasatiempos]) }
  rescue JSON::ParserError
    puts "Error: el archivo JSON está dañado. Se inicializará una lista vacía."
    []
  end
end

# Función para guardar datos en un archivo JSON
def guardar_personas(personas)
  File.write('persona.json', JSON.pretty_generate(personas.map(&:to_h)))
end

# Función para validar entrada de datos (ej.: entrada vacia o con caracteres erroneos)
def obtener_entrada(mensaje, tipo = :string, permitir_vacio = false)
  print mensaje
  loop do
    entrada = gets.chomp.strip
    return entrada if permitir_vacio && entrada.empty?  # Acepta vacío si está permitido
    return entrada unless entrada.empty?  # Normalmente no acepta vacío

    case tipo
    when :int
      return entrada.to_i if entrada.match?(/^\d+$/)
      print "Entrada inválida. Ingresa un número válido: "
    when :string
      print "Entrada inválida. No puede estar vacía: " unless permitir_vacio
    end
  end
end


# Función para ingresar nueva persona
def agregar_persona
  personas = cargar_personas
  id = Persona.generar_id(personas)

  nombre = obtener_entrada("Ingresa tu nombre: ")
  edad = obtener_entrada("Ingresa tu edad: ", :int)
  profesion = obtener_entrada("Ingrese profesión: ")

  puts "Ingresa tus pasatiempos (uno por línea, deja vacío para finalizar):"
  pasatiempos = []
  loop do
    entrada = gets.chomp.strip
    break if entrada.empty?
    pasatiempos << entrada
  end

  nueva_persona = Persona.new(id, nombre, edad, profesion, pasatiempos)
  personas << nueva_persona
  guardar_personas(personas)

  puts "¡Persona registrada exitosamente!"
end

# Función para mostrar todas las personas
def mostrar_personas
  personas = cargar_personas

  if personas.empty?
    puts "No hay personas registradas."
    return
  end

  puts "\nLista de personas registradas:\n\n"
  personas.each do |persona|
    puts <<~INFO
      Persona ##{persona.id}:
      Nombre: #{persona.nombre}
      Edad: #{persona.edad}
      Profesión: #{persona.profesion}
      Pasatiempos: #{persona.pasatiempos.join(', ')}
      ------------------------------
    INFO
  end
end


# Función para modificar una persona
def modificar_persona
  personas = cargar_personas
  mostrar_personas

  id = obtener_entrada("Ingresa el ID de la persona a modificar: ", :int).to_i
  persona = personas.find { |p| p.id.to_i == id.to_i }

  if persona
    puts "Modificando a #{persona.nombre}. Deja vacío para mantener el valor actual."

    nombre = obtener_entrada("Nuevo nombre (actual: #{persona.nombre}): ", :string, true)
    persona.nombre = nombre unless nombre.empty?

    edad = obtener_entrada("Nueva edad (actual: #{persona.edad}): ", :string, true)
    if edad.match?(/^\d+$/)
      persona.edad = edad.to_i
    end


    profesion = obtener_entrada("Nueva profesión (actual: #{persona.profesion}): ", :string, true)
    persona.profesion = profesion unless profesion.empty?


    puts "Nuevos pasatiempos (actuales: #{persona.pasatiempos.join(', ')})"
    puts "Ingresa uno por línea. Deja vacío para finalizar."
    nuevos_pasatiempos = []
    loop do
      entrada = gets.chomp.strip
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
  mostrar_personas  # Muestra la lista normal antes de eliminar

  id = obtener_entrada("Ingresa el ID de la persona a eliminar: ", :int)
  persona = personas.find { |p| p.id.to_i == id.to_i }  

  if persona
    print "¿Estás seguro de que deseas eliminar a #{persona.nombre}? (S/N): "
    confirmacion = gets.chomp.strip.upcase
    if confirmacion == 'S'
      personas = personas.reject { |p| p.id.to_i == id.to_i }  
      guardar_personas(personas)

      puts "Persona eliminada exitosamente."
      mostrar_personas  # Muestra la lista nuevamente después de eliminar
    else
      puts "Operación cancelada."
    end
  else
    puts "No se encontró ninguna persona con ese ID."
  end
end

# Menú principal
loop do
  puts "\nMenú Principal"
  puts "1) Agregar persona"
  puts "2) Mostrar personas registradas"
  puts "3) Modificar persona"
  puts "4) Eliminar persona"
  puts "5) Salir"
  opcion = obtener_entrada("Elige una opción: ")

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