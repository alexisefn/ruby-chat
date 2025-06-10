# 'lib/usuario.rb'

class Usuario
  # --- ATRIBUTOS ---
  attr_reader :username, :es_admin # Crea métodos para leer las instancias desde fuera, no cambiarlas directamente.
  attr_accessor :bloqueado         # Crea un método para leer y escribir el estado bloqueado.

  # --- MÉTODOS ---

  # Método especial llamado al crear un nuevo objeto Usuario con Usuario.new(...)
  # Usa keyword arguments (argumentos con nombre) para mayor claridad.
  def initialize(username:, password:, es_admin: false, bloqueado: false)
    # Las variables de instancia (@variable) guardan el estado de CADA objeto Usuario.
    @username = username
    @password = password
    @es_admin = es_admin
    @bloqueado = bloqueado
  end

  # Método para verificar si el usuario es administrador (devuelve true/false)
  def es_admin? # El '?' al final es una convención en Ruby para métodos que devuelven booleanos.
    @es_admin
  end

  # Método para verificar si el usuario está bloqueado (devuelve true/false)
  def esta_bloqueado?
    @bloqueado
  end

  # Método para verificar la contraseña:
  # Recibe la contraseña que el usuario intentó ingresar.
  # Devuelve true si coincide, false si no.
  # Es más seguro que crear un reader/accessor (attr_writer) para @password
  def autenticar(intento_password)
    @password == intento_password # Compara la contraseña guardada en la instancia (@password) con el intento.
  end

  # Método para marcar al usuario como bloqueado
  def bloquear! # El '!' al final es una convención para métodos que modifican el estado del objeto.
    self.bloqueado = true # Usa el 'setter' creado por attr_accessor :bloqueado
  end

  # Método para desmarcar al usuario como bloqueado
  def desbloquear!
    self.bloqueado = false # Usa el 'setter' creado por attr_accessor :bloqueado
  end

  # Método para convertir el objeto Usuario de vuelta a un Hash.
  def to_hash
    {
      "username" => @username,
      "password" => @password,
      "es_admin" => @es_admin,
      "bloqueado" => @bloqueado
    }
  end
end # Fin de la clase Usuario
