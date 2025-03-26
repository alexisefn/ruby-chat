# Validaciones
# Este módulo manejará la verificación de datos vacíos

module Autenticacion
  def verificar_dato_vacio(dato, mensaje_error)
    if dato.empty?
      puts mensaje_error
      return true
    end
    false
  end
end