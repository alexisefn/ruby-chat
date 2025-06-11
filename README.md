# Chat en Consola con Ruby

Este proyecto es una aplicación de chat básica desarrollada en Ruby, diseñada para funcionar en la consola. Su creación tuvo como objetivo principal **aplicar y consolidar los conocimientos adquiridos en mis estudios del lenguaje Ruby**, enfocándose en la Programación Orientada a Objetos (POO), el manejo de datos con SQLite (previamente con JSON), la interacción con el usuario y la modularización del código.

### Conceptos clave de Ruby aplicados

A lo largo de este proyecto, he puesto en práctica y profundizado mi comprensión en los siguientes aspectos de Ruby:

* **Programación Orientada a Objetos (POO):**
    * **Clases y Objetos:** Se utilizan múltiples clases como `ChatApp`, `Usuario`, `Mensaje`, `AlmacenamientoDB` y `Temas` para modelar las diferentes entidades y funcionalidades de la aplicación. Por ejemplo, `ChatApp` es la clase principal de la aplicación, `Usuario` representa a un usuario del chat, y `Mensaje` representa un mensaje enviado.
    * **Variables de Instancia (`@`):** Demostración del uso de variables de instancia para mantener el estado de cada objeto: `@usuario_actual` en `ChatApp` , `@username`, `@password`, `@es_admin`, `@bloqueado` en `Usuario` y `@id`, `@username`, `@timestamp`, `@texto` en `Mensaje`.
    * **Atributos (`attr_reader`, `attr_accessor`):** Utilización de `attr_reader` para permitir el acceso de solo lectura a atributos importantes (ej., `username`, `es_admin` en `Usuario`, y `id`, `username`, `timestamp`, `texto` en `Mensaje`) y `attr_accessor` para atributos que requieren lectura y escritura (ej., `bloqueado` en `Usuario` ).
    * **Métodos de Instancia:** Implementación de métodos para definir el comportamiento de los objetos, como `ejecutar` en `ChatApp` (que inicia la lógica principal del chat), `autenticar` en `Usuario` (para verificar la contraseña), y `to_s` en `Mensaje` (para obtener la representación en String del mensaje).
    * **Convenciones de Nombres:** Uso de convenciones de Ruby como `?` para métodos booleanos (`es_admin?`, `esta_bloqueado?`) y `!` para métodos que modifican el estado del objeto (`bloquear!`, `desbloquear!` ).
    * **Encapsulamiento y Métodos Privados:** Se utilizan métodos `private`  para ocultar detalles de implementación, como `cargar_datos_iniciales`  o `iniciar_sesion_o_registrar`, manteniendo la interfaz pública de la clase `ChatApp` limpia.

* **Manejo de Datos y Persistencia (SQLite3):**
    * **Integración con Bases de Datos:** Uso de la gema `sqlite3`  para la persistencia de datos, gestionando usuarios y mensajes en un archivo de base de datos (`db/chat_app.sqlite3`). La clase `AlmacenamientoDB` es la encargada de la interacción con la base de datos.
    * **Creación de Tablas con SQL:** Definición de esquemas de tablas (`usuarios`, `mensajes` ) directamente desde Ruby utilizando SQL.
    * **Claves Foráneas (`FOREIGN KEY`) y `ON DELETE CASCADE`:** Implementación de relaciones entre tablas y uso de `ON DELETE CASCADE` para asegurar la integridad referencial (ej., al borrar un usuario, todos sus mensajes se borrarán automáticamente).
    * **Mapeo de Datos:** Conversión de datos entre hashes de la base de datos y objetos Ruby (`Usuario`, `Mensaje` ) y viceversa. Los métodos `cargar_usuarios_como_objetos`  y `cargar_mensajes_como_objetos`  se encargan de esto.
    * **Manejo de Excepciones de Base de Datos:** Implementación de bloques `rescue` para capturar y manejar errores específicos de SQLite (ej., `SQLite3::ConstraintException` si el username ya existe en `agregar_usuario_obj`) y otros errores generales.

* **Control de Flujo y Estructuras de Datos:**
    * **Condicionales (`if/else`, `unless`):** Uso extensivo para la lógica de autenticación (ej., si el usuario existe o está bloqueado), validación de comandos (ej., si el usuario actual es administrador ), y manejo de diferentes escenarios.
    * **Bucles (`loop`, `each`):** Implementación de un bucle principal para el chat (`main_loop`)  y uso de `each` para iterar sobre colecciones de objetos (ej., `mensajes_objetos.each { |msg_obj| puts msg_obj }` para listar cada mensaje guardado).
    * **Colecciones (Arrays y Hashes):** Almacenamiento y manipulación de listas de objetos (`@usuarios_objetos`, `@mensajes_objetos` ) y uso de Hashes para representar datos y configuraciones.
    * **`find` y `reject!`:** Utilización de métodos de colección avanzados como `find` para buscar objetos específicos (ej., `usuario_encontrado = @usuarios_objetos.find { |usr_obj| usr_obj.username == username }`) y `reject!` para modificar colecciones en memoria (ej., `mensajes_objetos.reject! { |msg_obj| msg_obj.id == id_mensaje_borrar }` al borrar un mensaje).
    * **`case` statement:** Implementación de un `case` statement para procesar diferentes comandos del usuario (`/salir`, `/borrar`, `/bloquear`, `/desbloquear`) de manera estructurada.

* **Interacción con el Usuario y Seguridad Básica:**
    * **Entrada/Salida (`gets`, `puts`):** Manejo de la entrada del usuario (`gets.chomp`) y la salida de información en la consola (`puts`).
    * **Ocultar Contraseña (`io/console`):** Uso de la gema `io/console` y `STDIN.noecho`  para ocultar la entrada de contraseñas, mejorando la seguridad del usuario.
    * **Manejo de Comandos:** Implementación de comandos predefinidos (`/salir` , `/borrar` , `/bloquear` , `/desbloquear` ) con validación de permisos de administrador.

* **Modularización y Buenas Prácticas:**
    * **`require_relative`:** Uso para cargar archivos de clases y módulos locales, organizando el código en una estructura modular (ej., `main.rb` cargando `lib/chat_app.rb`, y `lib/chat_app.rb` cargando `almacenamiento_db`, `usuario`, `mensaje`, `temas`).
    * **Módulos (`module`):** Creación del módulo `Temas`  para centralizar la lógica de formateo y estilización de la salida en consola (`colorize` ), promoviendo la reutilización y la legibilidad. Incluye métodos para errores, éxitos, información, banners y separadores.
    * **Constantes (`.freeze`):** Definición de constantes para comandos (ej., `COMANDO_SALIR` ) y su uso con `.freeze` para asegurar que no sean modificadas accidentalmente.

### Cómo Ejecutar el Proyecto

Para probar esta aplicación y ver los conceptos de Ruby en acción:

1.  **Clona el repositorio:**
    ```bash
    git clone https://github.com/tu_usuario/tu_repo.git
    cd tu_repo
    ```
2.  **Instala las dependencias (Gems):**
    Asegúrate de tener [Bundler](https://bundler.io/) instalado (`gem install bundler`). Luego, en la raíz del proyecto, ejecuta:
    ```bash
    bundle install
    ```
3.  **Ejecuta la aplicación:**
    ```bash
    ruby main.rb
    ```

Una vez ejecutada, podrás registrarte o iniciar sesión y comenzar a interactuar con el chat. Prueba los comandos `/borrar`, `/bloquear`, `/desbloquear` si inicias sesión como un usuario administrador (puedes editar la base de datos `db/chat_app.sqlite3` con una herramienta como [DB Browser for SQLite](https://sqlitebrowser.org/) para establecer `es_admin` a `1` para un usuario).

### Reflexiones y Próximos Pasos

Este proyecto ha sido una excelente oportunidad para solidificar mis fundamentos en Ruby, especialmente en la arquitectura de aplicaciones orientadas a objetos y la persistencia de datos. El desafío de implementar la lógica de autenticación y los comandos de administración fue particularmente enriquecedor.

Como próximo paso, me gustaría explorar Rails y poder adaptar lo aprendido a este framework.
