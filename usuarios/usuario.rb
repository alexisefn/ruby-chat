# Definición de clases
# Este archivo contiene las clases Usuario y Administrador

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
