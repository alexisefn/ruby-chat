# 24/03/2025
# Mi tercer programa creado con Ruby !

require_relative 'gestor_usuarios'

archivo = "usuarios.json"
gestor = GestorUsuarios.new(archivo)

puts "¡Bienvenido!"

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
# ???