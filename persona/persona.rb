require 'json'

# Definir clase
class Persona
  attr_accessor :nombre, :edad, :profesion, :pasatiempo

  def initialize(nombre, edad, profesion, pasatiempo)
    @nombre = nombre
    @edad = edad
    @profesion = profesion
    @pasatiempo = pasatiempo
  end

  # Método para convertir datos en un hash (JSON)
  def to_h
    {
      nombre: @nombre,
      edad: @edad,
      profesion: @profesion,
      pasatiempo: @pasatiempo
    }
  end
end

# Función para cargar datos desde archivo JSON
def cargar_personas
  if File.exist?('persona.json') && !File.zero?('persona.json')
    file = File.read('persona.json')
    JSON.parse(file, symbolize_names: true) rescue []
  else
    []
  end
end

# Función para guardar datos en un archivo en un archivo JSON
def guardar_personas(personas)
  File.open('persona.json', 'w') do |file|
    file.write(JSON.pretty_generate(personas))
  end
end

# Ingresar nueva persona
print "Ingresa tu nombre: "
nombre = gets.chomp
print "Ingresa tu edad: "
edad = gets.chomp
print "Ingrese profesión: "
profesion = gets.chomp
print "Ingresa un pasatiempo: "
pasatiempo = gets.chomp

# Crear persona y agregarla a la lista
nueva_persona = Persona.new(nombre, edad, profesion, pasatiempo)
personas = cargar_personas

# Agregar persona al array
personas << nueva_persona.to_h

# Guardar persona
guardar_personas(personas)

puts "¡Persona registrada exitosamente!"