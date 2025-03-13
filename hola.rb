# 12/03/2025
# Mi primer programa en Ruby ^^

puts "¡Hola!"

def mostrar_mensaje
  puts "Ingresa algo y lo mostararé en pantalla"
  mensaje = gets.chomp
  
  loop do  
    puts "¿Cuantas veces quieres ver el mensaje?"
    repeticiones = gets.chomp
    
    begin
      numero = Integer(repeticiones)
      contador = 1
      
      loop do
        puts mensaje
        contador += 1
        break if contador > numero.to_i
      end
      break
    
    rescue ArgumentError
      puts "Lo siento, no ingresaste un número. Intentalo nuevamente."
    end
  end
end

loop do
  mostrar_mensaje
  print "¿Quieres ingresar algo más? (Y/N): "
  respuesta = gets.chomp.upcase
  
  break if respuesta == 'N'
end

puts "¡Hasta la próxima!"

# Notas
# Validar Y/N