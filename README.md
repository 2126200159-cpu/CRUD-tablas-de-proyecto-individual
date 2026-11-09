# Sistema de Biblioteca – CRUD con base de datos (JavaFX + MariaDB)

Aplicación de escritorio para gestionar una biblioteca. Los datos se guardan en
una base de datos **MariaDB/MySQL** (`biblioteca_db`) mediante JDBC, y las
imágenes se copian a una carpeta del proyecto guardando su ruta en la base.

**Autor:** Joshua Odin Montoya Flores  
**Institución:** Universidad Tecnológica de Jalisco (UTJ) – Programación Orientada a Objetos

## Tecnologías

- Java 17 o superior
- JavaFX (FXML, `TableView`, `ComboBox`, `DatePicker`, `FileChooser`, `ImageView`, `TextFormatter`)
- JDBC con MariaDB Connector/J
- MariaDB 10.4 / MySQL 8 (XAMPP + phpMyAdmin)
- Maven y NetBeans

## Base de datos

Los scripts están en [`base_de_datos/`](base_de_datos/):

| Archivo | Para qué sirve |
|---|---|
| `01_crear_base_de_datos.sql` | Crea `biblioteca_db` con sus 7 tablas, llaves primarias, foráneas y restricciones |
| `02_datos_de_prueba.sql` | Datos de ejemplo (opcional) |
| `03_agregar_columnas_imagen.sql` | Solo si la base se creó con una versión anterior del script 01 |

Tablas: `estado_administrador`, `persona`, `administrador`, `lector`,
`categoria`, `editorial` y `libro`. No se incluyen `préstamo` ni
`detalle_préstamo`. `administrador` y `lector` heredan de `persona`
(su llave primaria es también foránea a `persona`).

La conexión se configura en `dao/ConexionBD.java` (por defecto
`localhost:3306`, usuario `root`, sin contraseña).

## Estructura del proyecto

```
src/main/java/edu/utj/evnd/poo/bibliotecaproyec/
├── model/        Persona (abstract), Administrador, Lector, Libro, Categoria, Editorial, Imagenable
├── enums/        EstadoAdministrador
├── dao/          Dao<T>, ConexionBD, PersonaDao, LibroDao, CategoriaDao, EditorialDao
├── service/      ImagenService (copiar y borrar imágenes)
├── controller/   CrudController<T> (CRUD, validaciones e imagen), PersonaController,
│                 LibroController, CategoriaController, EditorialController, MenuController
├── App.java, Main.java
src/main/resources/
├── menu.fxml, persona.fxml, libro.fxml, categoria.fxml, editorial.fxml
└── styles/app.css
```

**Separación de responsabilidades:** el *modelo* conserva datos y reglas; los
*DAO* ejecutan las consultas SQL; el *servicio* gestiona las imágenes; los
*controladores* manejan eventos, validaciones y botones; los *FXML/CSS* solo
presentan los controles.

## Vistas (todas las tablas, excepto préstamo y detalle de préstamo)

| Vista | Tablas |
|---|---|
| Personas | `persona` + `administrador` + `lector` en una sola pantalla; el combo **Tipo** muestra los campos del administrador o del lector |
| Libros | `libro` (con listas de editorial y categoría cargadas desde la base) |
| Categorías | `categoria` |
| Editoriales | `editorial` |

Cada vista tiene formulario, tabla de solo lectura y los botones Nuevo, Guardar,
Editar, Eliminar, Validar y Limpiar / Cancelar, además de búsqueda
(**Buscar** / **Mostrar todos**) hecha con consultas SQL (`LIKE`).

## Gestión de imágenes

1. **Seleccionar:** `FileChooser` (png, jpg, jpeg, gif; máximo 5 MB).
2. **Vista previa:** la imagen se carga en un `ImageView`.
3. **Guardar:** se **copia** a la carpeta `imagenes/` del proyecto con nombre
   único (`prefijo_marcaDeTiempo.ext`) y la **ruta relativa** se guarda en la
   columna `url_imagen` al hacer el `INSERT`.
4. **Actualizar:** si se elige otra imagen, se copia la nueva, se guarda su ruta
   con el `UPDATE` y se borra la anterior. Si no se elige otra, se conserva la actual.
5. **Mostrar:** al seleccionar un registro de la tabla, su imagen se carga en el `ImageView`.
6. **Eliminar:** la imagen solo se borra del disco **después** de que el
   `DELETE` se ejecutó correctamente en la base. Si la base rechaza la
   operación (p. ej. el registro está relacionado), la imagen se conserva.
   Del mismo modo, si el `INSERT`/`UPDATE` falla, se borra la copia recién creada.

La carpeta `imagenes/` se crea sola y no se sube al repositorio.

## Validaciones en tiempo real

- **Filtros de teclado** (`TextFormatter`): ID y teléfono solo dígitos; CURP y RFC
  solo letras y números en mayúsculas; nombres solo letras; precio y multa
  decimales; etc. Un carácter no permitido se rechaza y se avisa debajo del campo.
- **Mensajes debajo de cada control** (un `Label` por campo): «Este campo es
  obligatorio.» o el formato esperado. Se actualizan al escribir, borrar, pegar o elegir.
- **Botón Validar:** revisa todos los campos y muestra una alerta si son válidos; no guarda nada.
- **Botones:** al iniciar solo están activos Nuevo y Validar; **Guardar** se
  habilita únicamente con el formulario válido; **Editar** y **Eliminar** solo con
  una fila seleccionada.
- Los valores únicos repetidos (ID, CURP, usuario, ISBN…) y los registros
  relacionados los controla la base de datos y se informan con un mensaje claro.

## Ejecución

1. Iniciar **Apache** y **MySQL/MariaDB** en XAMPP.
2. En phpMyAdmin, importar `01_crear_base_de_datos.sql` (y opcionalmente `02_datos_de_prueba.sql`).
3. Abrir el proyecto en NetBeans, hacer **Clean and Build** y ejecutar la clase `Main`.

## Evidencias

Capturas en la carpeta [`capturas/`](capturas/): base de datos creada, cada
vista, operaciones CRUD, imágenes y validaciones.
