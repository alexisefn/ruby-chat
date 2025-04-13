class Usuario
  # --- Atributos ---
  # attr_reader :nombre => crea un método para LEER la variable de instancia @nombre
  # attr_writer :nombre => crea un método para ESCRIBIR la variable de instancia @nombre
  # attr_accessor :nombre => crea ambos métodos (leer y escribir)

  attr_reader :username, :es_admin # Solo queremos leer estos desde fuera, no cambiarlos directamente.
  attr_accessor :bloqueado         # Queremos leer y escribir el estado bloqueado.

  # No creamos un reader/accessor para @password por seguridad,
  # se verifica a través del método autenticar.

  # --- Métodos ---

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
  # El '?' al final es una convención en Ruby para métodos que devuelven booleanos.
  def es_admin?
    @es_admin
  end

  # Método para verificar si el usuario está bloqueado (devuelve true/false)
  def esta_bloqueado?
    @bloqueado
  end

  # Método para verificar la contraseña
  # Recibe la contraseña que el usuario intentó ingresar.
  # Devuelve true si coincide, false si no.
  def autenticar(intento_password)
    # Compara la contraseña guardada en la instancia (@password) con el intento.
    @password == intento_password
  end

  # Método para marcar al usuario como bloqueado
  # El '!' al final es una convención para métodos que modifican el estado del objeto.
  def bloquear!
    # Usa el 'setter' creado por attr_accessor :bloqueado
    self.bloqueado = true # O directamente @bloqueado = true
  end

  # Método para desmarcar al usuario como bloqueado
  def desbloquear!
    self.bloqueado = false # O directamente @bloqueado = false
  end

  # Método útil para convertir el objeto Usuario de vuelta a un Hash.
  # Esto será práctico cuando necesitemos guardar los datos en JSON.
  def to_hash
    {
      "username" => @username,
      "password" => @password,
      "es_admin" => @es_admin,
      "bloqueado" => @bloqueado
    }
  end
end