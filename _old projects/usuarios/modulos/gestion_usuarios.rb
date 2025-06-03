# Gestión de Usuarios
# Este módulo contendrá los métodos para registrar, iniciar sesión, modificar y eliminar usuarios.

require 'json'
require_relative '../usuario'
require_relative 'autenticacion'

module GestionUsuarios
  include Autenticacion

  def cargar_usuarios
    if File.exist?(@archivo)
      contenido = File.read(@archivo)
      JSON.parse(contenido) rescue []
    else
      []
    end
  end

  def guardar_usuarios
    File.open(@archivo, "w") do |f| # f = archivo a modificar (en este caso, el JSON)
      f.write(JSON.pretty_generate(@usuarios))
    end
  end

  def registrar_usuario
    puts "Ingrese su nombre de usuario:"
    username = gets.chomp
    
    return if verificar_dato_vacio(username, "No puede dejar este campo vacío.")

    # Verificar si el nombre de usuario ya está registrado
    if @usuarios.any? { |u| u["username"] == username }
      puts "El nombre de usuario ya está registrado. Por favor, elija otro."
      return
    end

    puts "Ingrese su contraseña:"
    password = gets.chomp

    return if verificar_dato_vacio(password, "No puede dejar este campo vacío.")
      
    # Por defecto, los nuevos usuarios serán tipo "Usuario"
    # Sólo el primer usuario registrado será Administrador
    tipo = @usuarios.empty? ? "Administrador" : "Usuario"

    usuario = Usuario.new(username, password, tipo)

    @usuarios << usuario.to_hash # << = agregar elementos a un array
    guardar_usuarios
    puts "¡Registro exitoso!"
  end

  def iniciar_sesion
    usuario = nil
  
    loop do
      puts "Ingrese su nombre de usuario:"
      username = gets.chomp.strip
  
      puts "Ingrese su contraseña:"
      password = gets.chomp.strip
  
      usuario = @usuarios.find { |u| u["username"] == username && u["password"] == password }
  
      if usuario
        puts "¡Bienvenido, #{usuario["username"]}!"
        return usuario
      else
        puts "Nombre de usuario o contraseña incorrectos. Intente nuevamente."
      end
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
    usuario = nil
    loop do
      puts "Ingrese el nombre de usuario al que desea cambiar la contraseña:"
      username = gets.chomp.strip
      usuario = @usuarios.find { |u| u["username"] == username }
  
      if usuario
        break # Si se encuentra el usuario, se sale del bucle
      else
        puts "Usuario no encontrado. Intente nuevamente."
      end
    end
  
    # Pedir nueva contraseña
    nueva_password = ""
    loop do
      puts "Ingrese la nueva contraseña para #{usuario["username"]}:"
      nueva_password = gets.chomp.strip
      if nueva_password.empty?
        puts "La contraseña no puede estar vacía."
      else
        break
      end
    end
  
    usuario["password"] = nueva_password
    guardar_usuarios
    puts "Contraseña de #{usuario["username"]} modificada correctamente."
  end

  def eliminar_usuario(administrador)
    usuario = nil
    loop do
      puts "Ingrese el nombre de usuario a eliminar:"
      username = gets.chomp.strip
      usuario = @usuarios.find { |u| u["username"] == username }
  
      if usuario
        break # Si se encuentra el usuario, se sale del bucle
      else
        puts "Usuario no encontrado. Intente nuevamente."
      end
    end
  
    if usuario["username"] == administrador["username"]
      puts "No puedes eliminarte a ti mismo."
      return
    end
    
    @usuarios.delete(usuario)
    guardar_usuarios
    puts "Usuario #{usuario["username"]} eliminado correctamente."
  end

  def listar_usuarios
    puts "Lista de usuarios:"
    @usuarios.each { |u| puts "- #{u["username"]} (#{u["tipo"]})" }
  end
end