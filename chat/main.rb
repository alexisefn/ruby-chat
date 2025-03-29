# 29/03/2025
# Mi cuarto proyecto en Ruby. 
# :)

require 'json'

# Archivo donde se guardan los usuarios
ARCHIVO_USUARIOS = 'usuarios.json'

def cargar_usuarios
  if File.exist?(ARCHIVO_USUARIOS)
    JSON.parse(File.read(ARCHIVO_USUARIOS))
  else
    []
  end
end

def guardar_usuarios(usuarios)
  File.write(ARCHIVO_USUARIOS, JSON.pretty_generate(usuarios))
end

def registrar_usuario
  usuarios = cargar_usuarios
  
  print "Nombre de usuario: "
  username = gets.chomp.strip
  
  print "Contraseña: "
  password = gets.chomp.strip
  
  # Rol por defecto es "usuario"
  rol = "usuario"
  
  # Validaciones
  if username.empty? || password.empty?
    puts "Error: Nombre y contraseña no pueden estar vacíos."
    return
  end
  
  # Verificar si el usuario ya existe
  if usuarios.any? { |u| u["username"].downcase == username.downcase }
    puts "Error: El usuario ya existe."
    return
  end
  
  # Generar una ID basada en el último ID registrado
  if usuarios.empty?
    id = 1  # Si no hay usuarios, el primer ID será 1
  else
    id = usuarios.last["id"] + 1  # Incrementa el ID del último usuario
  end
  
  # Crear usuario y agregarlo al JSON
  nuevo_usuario = {
    "id" => id,
    "username" => username, # Nombre del usuario guardado
    "password" => password,
    "rol" => rol
  }
  usuarios << nuevo_usuario
  guardar_usuarios(usuarios)
  
  puts "Usuario registrado con éxito."
end

if __FILE__ == $0
  registrar_usuario
end