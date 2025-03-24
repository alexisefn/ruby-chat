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
    { "username" => @username, "password" => @password, "tipo" => @tipo}
  end

  def ver_perfil
    puts "Nombre de Usuario: #{@username}"
    puts "tipo: #{@tipo}"
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
    tipo = "Usuario"
    tipo = "Administrador" if @usuarios.empty?

    usuario = Usuario.new(username, password, tipo)

    @usuarios << usuario.to_hash
    guardar_usuarios
    puts "¡Registro exitoso"
  end

  def iniciar_sesion
    puts "Ingrese su nombre de usuario:"
    username = gets.chomp
    puts "Ingrese su contraseña:"
    password = gets.chomp

    usuario = @usuarios.find { |u| u["username"] == username && u["password"] == password}
      
    if usuario
      puts "¡Bienvenido, #{usuario["username"]}"
      return usuario
    else
      puts "Nombre de usuario o contraseña incorrectos."
      return nil
    end
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
      puts "Bienvenido, #{usuario_actual["nombre"]}."
      if usuario_actual["tipo"] == "admin"
        puts "Eres administrador. Puedes gestionar usuarios."
      else
        puts "Eres usuario. Solo puedes ver tu perfil."
      end
    end
  when 3
    puts "¡Hasta la próxima!"
    break
  else
    puts "Opción inválida. Intente nuevamente."
  end
end