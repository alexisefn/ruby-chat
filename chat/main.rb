# 29/03/2025
# Mi cuarto proyecto en Ruby. 
# (¡Suerte!)

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
    puts "Nombre y contraseña no pueden estar vacíos."
    return
  end
  
  # Verificar si el usuario ya existe
  if usuarios.any? { |u| u["username"].downcase == username.downcase }
    puts "El usuario ya existe."
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

def iniciar_sesion
  usuarios = cargar_usuarios

  puts "Ingrese su nombre de usuario:"
  username = gets.chomp.strip
  puts "Ingrese su contraseña:"
  password = gets.chomp.strip

  usuario = usuarios.find { |u| u["username"].downcase == username.downcase && u["password"] == password}

  if usuario
    puts "¡Bienvenido. #{usuario["username"]}!"
    return usuario
  else
    puts "Nombre de usuario o contraseña incorrectos. Intente nuevamente."
  end
end

if __FILE__ == $0
  loop do
    puts "Seleccione una opción:"
    puts "1) Registrar usuario"
    puts "2) Iniciar sesión"
    puts "3) Salir"
    print "Opción: "
    opcion = gets.chomp.to_i

    case opcion
    when 1
      registrar_usuario
    when 2
      usuario_actual = iniciar_sesion
      if usuario_actual["rol"] == "administrador"
        loop do 
          puts "\nMenú Administrador:"
          puts "1) Cerrar sesión"
          opcion_admin = gets.chomp.to_i

          case opcion_admin
          when 1
            puts "Cerrando sesión..."
            break
          else
            puts "Opción invalida. Intente nuevamente."
          end
        end
      else
        loop do 
          puts "\nMenú Usuario:"
          puts "1) Cerrar sesión"
          opcion_admin = gets.chomp.to_i

          case opcion_admin
          when 1
            puts "Cerrando sesión..."
            break
          else
            puts "Opción invalida. Intente nuevamente."
          end
        end
      end
    when 3
      puts "Saliendo del programa. ¡Hasta la próxima!"
      break
    else
      puts "Opción invalida. Intente nuevamente."
    end
  end
end