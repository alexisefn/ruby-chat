# Clase GestorUsuarios
# Este archivo incluye los módulos y manejará las acciones de usuario

require_relative 'modulos/gestion_usuarios'

class GestorUsuarios
  include GestionUsuarios

  def initialize(archivo)
    @archivo = archivo
    @usuarios = cargar_usuarios
  end
end