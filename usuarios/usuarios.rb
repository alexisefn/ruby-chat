# 24/03/2025
# Mi tercer programa creado con Ruby ಠ_ಠ !

require 'json'

# Clase base Usuario
class Usuario
  attr_accessor :username, :password, :tipo

  def initialize(username, password, tipo)
    @username = username
    @password = password
    @tipo = tipo # "Administrador" o "Usuario"
  end
  
  def to_hash
    { "username" => @username, "password" => @password, "tipo" => @tipo }
  end

  def ver_perfil
    puts "Nombre de Usuario: #{@username}"
    puts "Tipo: #{@tipo}"
  end
end

# Clase Administrador que hereda de Usuario
class Administrador < Usuario
  def initialize(username, password)
    super(username, password, "Administrador")
  end
end

# Clase para gestionar usuarios
class GestorUsuarios
  def initialize(archivo)
    @archivo = archivo
    @usuarios = cargar_usuarios
  end

  def cargar_usuarios
    if File.exist?(@archivo)
      contenido = File.read(@archivo)
      JSON.parse(contenido) rescue []
    else
      []
    end
  end

  def guardar_usuarios
    File.open(@archivo, "w") do |f|
      f.write(JSON.pretty_generate(@usuarios))
    end
  end

  def registrar_usuario
    puts "Ingrese su nombre de usuario:"
    username = gets.chomp
    puts "Ingrese su contraseña:"
    password = gets.chomp
  
    # Por defecto, los nuevos usuarios serán tipo "Usuario"
    # Sólo el primer usuario registrado será Administrador
    tipo = @usuarios.empty? ? "Administrador" : "Usuario"

    usuario = Usuario.new(username, password, tipo)

    @usuarios << usuario.to_hash
    guardar_usuarios
    puts "¡Registro exitoso!"
  end

  def iniciar_sesion
    puts "Ingrese su nombre de usuario:"
    username = gets.chomp
    puts "Ingrese su contraseña:"
    password = gets.chomp

    usuario = @usuarios.find { |u| u["username"] == username && u["password"] == password }
      
    if usuario
      puts "¡Bienvenido, #{usuario["username"]}!"
      return usuario
    else
      puts "Nombre de usuario o contraseña incorrectos."
      return nil
    end
  end

  def modificar_password(usuario)
    puts "Ingrese su nueva contraseña:"
    nueva_password = gets.chomp
    usuario["password"] = nueva_password
    guardar_usuarios
    puts "Contraseña modificada exitosamente."
  end

  def modificar_password_otro
    puts "Ingrese el nombre de usuario al que desea cambiar la contraseña:"
    username = gets.chomp
    usuario = @usuarios.find { |u| u["username"] == username }

    if usuario
      puts "Ingrese la nueva contraseña para #{username}:"
      nueva_password = gets.chomp
      usuario["password"] = nueva_password
      guardar_usuarios
      puts "Contraseña de #{username} modificada correctamente."
    else
      puts "Usuario no encontrado."
    end
  end

  def eliminar_usuario(administrador)
    puts "Ingrese el nombre de usuario a eliminar:"
    username = gets.chomp
    usuario = @usuarios.find { |u| u["username"] == username }

    if usuario
      if usuario["username"] == administrador["username"]
        puts "No puedes eliminarte a ti mismo."
      else
        @usuarios.delete(usuario)
        guardar_usuarios
        puts "Usuario #{username} eliminado correctamente."
      end
    else
      puts "Usuario no encontrado."
    end
  end

  def listar_usuarios
    puts "Lista de usuarios:"
    @usuarios.each { |u| puts "- #{u["username"]} (#{u["tipo"]})" }
  end
end

# ------------------ FLUJO PRINCIPAL ------------------
archivo = "usuarios.json"
gestor = GestorUsuarios.new(archivo)

puts "¡Bienvenido al sistema de autenticación!"

loop do
  puts "\n¿Qué desea hacer?"
  puts "1. Registrarse"
  puts "2. Iniciar sesión"
  puts "3. Salir"
  opcion = gets.chomp.to_i

  case opcion
  when 1
    gestor.registrar_usuario
  when 2
    usuario_actual = gestor.iniciar_sesion
    if usuario_actual
      if usuario_actual["tipo"] == "Administrador"
        loop do
          puts "\nMenú Administrador:"
          puts "1. Ver lista de usuarios"
          puts "2. Modificar contraseña"
          puts "3. Modificar contraseña de otro usuario"
          puts "4. Eliminar usuario"
          puts "5. Cerrar sesión"
          opcion_admin = gets.chomp.to_i

          case opcion_admin
          when 1
            gestor.listar_usuarios
          when 2
            gestor.modificar_password(usuario_actual)
          when 3
            gestor.modificar_password_otro
          when 4
            gestor.eliminar_usuario(usuario_actual)
          when 5
            puts "Cerrando sesión..."
            break
          else
            puts "Opción inválida. Intente nuevamente."
          end
        end
      else
        loop do
          puts "\nMenú Usuario:"
          puts "1. Modificar contraseña"
          puts "2. Cerrar sesión"
          opcion_usuario = gets.chomp.to_i

          case opcion_usuario
          when 1
            gestor.modificar_password(usuario_actual)
          when 2
            puts "Cerrando sesión..."
            break
          else
            puts "Opción inválida. Intente nuevamente."
          end
        end
      end
    end
  when 3
    puts "¡Hasta la próxima!"
    break
  else
    puts "Opción inválida. Intente nuevamente."
  end
end

# Siguiente objetivo:
# Agregar métodos para:
# - Modificar contraseña (todos los usuarios)
# - Eliminar usuarios (Sólo Administrador)