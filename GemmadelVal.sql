
# CREACIÓN DE BASE DE DATOS Y TABLAS:

DROP DATABASE IF EXISTS TareaGemmadelVal; -- Eliminamos, en el caso de que haya existido, todos los datos de esa base de datos y los creamos de nuevo a continuación.
CREATE DATABASE TareaGemmadelVal; -- Creamos la base de datos.
USE TareaGemmadelVal; -- Indicamos que la vamos a utilizar.
DROP TABLE IF EXISTS pais, empresa, empleado, aplicacion, tienda, usuario, 
categoria, desarrolla, vinculo, clasificacion, subida, descarga; /* Con esta última línea 
de código borramos las tablas que puedan existir con el mismo nombre para pasar a crearlas de 
nuevo: */

-- Comenzamos creando las tablas de las diferentes entidades con sus atributos y dominios.

# A pesar de que pais sólo se nombra un par de veces en el enunciado, se decide establecer el mismo 
# como entidad ya que ayuda a mantener la consistencia de los datos. 

# Concretamente, esta entidad se menciona al hablar de dónde se pagan los impuestos y de dónde son los usuarios que descargan aplicaciones.

CREATE TABLE pais (
    nombreP VARCHAR(15) PRIMARY KEY UNIQUE NOT NULL -- Introducimos las restricciones UNIQUE NOT NULL.
);
CREATE TABLE empresa (
    codigoE NUMERIC(2,0) PRIMARY KEY, -- Indicamos que es la clave principal.
    nombreE VARCHAR(10) NOT NULL,
    anioCreac YEAR,
    correoE VARCHAR(30),
    webE VARCHAR(30),
	paisTrib VARCHAR(15),
    FOREIGN KEY (paisTrib) -- Indicamos así que se trata de la clave ajena.
        REFERENCES pais (nombreP) -- En esta línea se especifica donde esta clave es principal (en qué entidad) y cómo se llamaba en la misma.
        ON DELETE RESTRICT ON UPDATE RESTRICT -- Introducimos la restricción a la hora de borrado y actualización de datos.
);
CREATE TABLE empleado (
    dniEmpl CHAR(9) PRIMARY KEY,
    nombreEmpl VARCHAR(20),
    telefonoEmpl NUMERIC(9,0) UNIQUE NOT NULL,
	correoEmpl VARCHAR(30) UNIQUE NOT NULL, -- Podemos afirmar que tanto el telefonoEmpl como el correoEmpl son claves candidatas.
	codigoEmplActualidad NUMERIC(3,0) DEFAULT NULL, -- Introducimos este dato para indicar qué empleados trabajan en la actualidad en la empresa.
	fechaInicio DATE DEFAULT NULL, -- Como decimos qué empleados trabajan en la actualidad en la empresa, necesitamos saber la fecha de inicio para que el dato cobre sentido.
    calle VARCHAR(30) NOT NULL, -- Dirección es un atributo multivalorado (como ya hemos indicado en el Diagrama Entidad-Relación) formado por tres atributos: calle, numero y cPostal.
    numero NUMERIC(2,0) NOT NULL,
    cPostal NUMERIC(5,0) NOT NULL,
    FOREIGN KEY (codigoEmplActualidad)
        REFERENCES empresa (codigoE)
        ON DELETE SET NULL ON UPDATE CASCADE -- Esta línea de código indica que se puede editar pero en ningún caso desaparece el empleado.
);
CREATE TABLE aplicacion (
	codigoAp INT AUTO_INCREMENT PRIMARY KEY, -- AUTO_INCREMENT es una restricción de integridad que evita pérdidas en la consistencia de los datos.
    nombreAp VARCHAR(15) UNIQUE KEY,
	dniJefe CHAR(9) NOT NULL, -- Siendo dniJefe quien dirige el desarrollo de la aplicación.
	precioAp NUMERIC(4,2) DEFAULT (0), -- En caso de no establecerse un precio, este sería de cero.
    memoriaAp NUMERIC(4,0) NOT NULL,
    FOREIGN KEY (dniJefe)
        REFERENCES empleado (dniEmpl)
        ON DELETE RESTRICT ON UPDATE RESTRICT -- Como ya hemos mencionado, con esta restricción no se permite la actualizacion de datos ni el borrado de los mismos.
);
CREATE TABLE tienda (
    nombreT VARCHAR(20) PRIMARY KEY,
    gestion VARCHAR(15) NOT NULL,
    webT VARCHAR(50) UNIQUE NOT NULL -- Este tipo de restricción, UNIQUE, permite identificar de manera exclusiva cada registro.
);
CREATE TABLE usuario (
    numeroCuenta NUMERIC(9,0) PRIMARY KEY, -- Simplificamos el atributo numeroCuenta a nueve dígitos para simplificar el trabajo con los datos, ya que una cuenta normal tendría unos veinte dígitos.
    nombre VARCHAR(20),
    direccion VARCHAR(30)
);
CREATE TABLE categoria (
    descripcionCat VARCHAR(20) PRIMARY KEY
);

/* A continuación creamos las tablas que corresponden a las relaciones entre las diferentes 
entidades, también con sus respectivos atributos y dominios. Recordemos que se representan sólo las relaciones N:M. */

CREATE TABLE vinculo (
    dniV CHAR(9) NOT NULL,
    codEmplV NUMERIC(3,0) NOT NULL,
    fechaInicio DATE,
    fechaFin DATE,
    FOREIGN KEY (dniV)
        REFERENCES empleado (dniEmpl)
        ON DELETE RESTRICT ON UPDATE RESTRICT, -- Se restringe el borrado y actualización de las claves.
    FOREIGN KEY (codEmplV)
        REFERENCES empresa (codigoE)
        ON DELETE RESTRICT ON UPDATE RESTRICT
);
CREATE TABLE desarrolla (
    codigoApDesa INT NOT NULL,
    dniDesa CHAR(9) NOT NULL,
    codigoEmpl NUMERIC(3,0) NOT NULL,
    fechaInicio DATE, -- El tipo de dato DATE sirve para almacenar una fecha con el formato DD-MM-AA.
    fechaFin DATE,
    FOREIGN KEY (codigoApDesa)
        REFERENCES aplicacion (codigoAp)
        ON DELETE RESTRICT ON UPDATE RESTRICT,
    FOREIGN KEY (dniDesa)
        REFERENCES empleado (dniEmpl)
        ON DELETE RESTRICT ON UPDATE RESTRICT,
	FOREIGN KEY (codigoEmpl)
        REFERENCES empresa (codigoE)
        ON DELETE RESTRICT ON UPDATE RESTRICT
);
CREATE TABLE subida (
    nombreTSub VARCHAR(20) NOT NULL,
    codigoApSub INT NOT NULL,
    UNIQUE (nombreTSub,codigoApSub),
    FOREIGN KEY (nombreTSub)
        REFERENCES tienda (nombreT)
        ON DELETE CASCADE ON UPDATE CASCADE, -- Con esta línea especificamos que se permite el borrado y actualización de datos en caso de que suceda con las claves primarias.
    FOREIGN KEY (codigoApSub)
        REFERENCES aplicacion (codigoAp)
        ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE descarga (
    codigoApDesc INT NOT NULL,
    nombreTDesc VARCHAR(20) NOT NULL,
    numeroCuentaDesc NUMERIC(9,0) NOT NULL,
	paisDesc VARCHAR(15) NOT NULL,
	telefonoDesc NUMERIC (9,0) NOT NULL,
	fechaDesc DATE,
	comentario VARCHAR(50),
    puntuacion NUMERIC(1,0), 
    CHECK (Puntuacion >= 0 AND Puntuacion <= 5), -- Con la restricción CHECK especificamos los valores que se aceptan en un campo, evitando así que se ingresen valores inapropiados.
	UNIQUE (codigoApDesc,numeroCuentaDesc),
    FOREIGN KEY (codigoApDesc)
        REFERENCES aplicacion (codigoAP)
        ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (nombreTDesc)
		REFERENCES tienda (nombreT)
		ON DELETE RESTRICT ON UPDATE CASCADE, 
	FOREIGN KEY (numeroCuentaDesc)
        REFERENCES usuario (numeroCuenta)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (paisDesc)
        REFERENCES pais (nombreP)
        ON DELETE RESTRICT ON UPDATE RESTRICT
);
CREATE TABLE clasificacion (
    codigoApClas INT NOT NULL,
    nombreClas VARCHAR(10) NOT NULL,
    UNIQUE (codigoApClas,nombreClas), 
    FOREIGN KEY (codigoApClas)
        REFERENCES aplicacion (codigoAp)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (nombreClas)
        REFERENCES categoria (descripcionCat)
        ON DELETE CASCADE ON UPDATE CASCADE
);

# INSERCIÓN DE DATOS EN LA BASE:

-- Seguimos el orden establecido en la creación de tablas.

-- Comenzamos con la entidad tienda y procedemos a añadir los datos con código. Fuente: enunciado de la tarea.

INSERT INTO tienda VALUES
	('App Store', 'Apple', 'https://www.apple.com/es/ios/app-store/'),
    ('Google Play Store' ,	'Google Android', 'https://play.google.com/store/apps'),
	('Appworld', 'Blackberry', 'https://appworld.blackberry.com/webstore/'),
    ('Market Place', 'Windows Phone', 'https://www.microsoft.com/it-it/store/apps'),
    ('OVI Store', 'Nokia', 'http://ovi.sigma.apps.bemobi.com/es_it/?ecid=1'),
	('Amazon Appstore','Amazon','https://www.amazon.es/mobile-apps');

/* Seguimos con la entidad pais e incluimos los datos de los 
países que más apps desarrollan en el mundo. Fuente: HackerRank. */

INSERT INTO pais VALUES
	('China'),('Rusia'),('Polonia'),('Suiza'),('Hungria'),
	('Japon'),('Taiwan'),('Francia'),('Italia'),('Espania'),
	('Estados Unidos');
        
-- Cargamos los datos para la tabla empleado esta vez de una manera distinta, como un archivo externo (.csv).

LOAD DATA INFILE  '/usr/local/mysql/empleado.csv' 
	IGNORE INTO TABLE empleado
	FIELDS TERMINATED BY ';'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS;
	
-- Cargamos datos con código para categoria. Fuente: principales categorías de apps en Google Play.

INSERT INTO categoria VALUES
    ('Fotografia'), ('Familia'), ('Musica y audio'), ('Entretenimiento'), 
    ('Compras'), ('Personalización'), ('Social'), ('Comunicacion'), ('Popular');

-- En empresa.

LOAD DATA INFILE  '/usr/local/mysql/empresa.csv' 
	IGNORE INTO TABLE empresa
	FIELDS TERMINATED BY ';'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS;
    
-- En aplicacion.

LOAD DATA INFILE  '/usr/local/mysql/aplicacion.csv' 
	IGNORE INTO TABLE aplicacion
	FIELDS TERMINATED BY ';'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS;
        
-- En usuario.

LOAD DATA INFILE  '/usr/local/mysql/usuario.csv' 
	IGNORE INTO TABLE usuario
	FIELDS TERMINATED BY ';'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS;

-- Finalmente insertamos los datos pertenecientes a las relaciones:

LOAD DATA INFILE  '/usr/local/mysql/vinculo.csv' 
	IGNORE INTO TABLE vinculo
	FIELDS TERMINATED BY ';'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS;
    
LOAD DATA INFILE  '/usr/local/mysql/desarrolla.csv' 
	IGNORE INTO TABLE desarrolla
	FIELDS TERMINATED BY ';'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS;
    
INSERT INTO subida VALUES
	('App Store', 1), ('Appworld', 2), ('Market Place', 3), ('Google Play Store', 4), ('OVI Store', 5), ('Google Play Store', 6), 
    ('Amazon Appstore', 7), ('Market Place', 8), ('App Store', 9);
    
LOAD DATA INFILE  '/usr/local/mysql/descarga.csv' 
	IGNORE INTO TABLE descarga
	FIELDS TERMINATED BY ';'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS;

INSERT INTO clasificacion VALUES
	(1,'Musica y audio'), (1,'Popular'), (2,'Social'), (2,'Comunicacion'), (2,'Popular'), (3,'Fotografia'), (3,'Entretenimiento'), 
    (3,'Comunicacion'), (4,'Compras'), (4,'Popular'), (5,'Familia'), (5,'Personalización'), (6,'Popular'), (7,'Entretenimiento'), 
    (7,'Social'), (8,'Personalización'), (9, 'Musica y audio'), (9,'Popular');
    
# CONSULTAS PARA LA BASE DE DATOS:
 
-- A continuación procedemos a realizar las consultas:

/* 1. Indicar el nombre de los empleados cuyo código de empleado es menor de 50. */

SELECT nombreEmpl
FROM empleado
WHERE codigoEmplActualidad<50;

/* 2. ¿Cuáles son las 4 aplicaciones que más memoria del teléfono utilizan? */

SELECT nombreAp
FROM aplicacion
ORDER BY memoriaAp DESC
LIMIT 4;

/* 3. ¿En qué país tributan las empresas que se crearon después del 2001? */

SELECT paisTrib
FROM empresa
WHERE anioCreac>2001;

/* 4. DNI y código de empleado de quienes han desarrollado la aplicación con el código 7. */

SELECT dniDesa, codigoEmpl
FROM desarrolla
WHERE codigoApDesa=7;

/* 6.Tienda y nombre aplicación de las que tienen un 5 como puntuación de usuario. */

SELECT nombreTDesc, nombreAp
FROM descarga INNER JOIN aplicacion
WHERE puntuacion=5;

/* 7. Precio máximo y mínimo de las aplicaciones. */

SELECT min(precioAp), max(precioAp)
FROM aplicacion;

/* 8. Nombre y precios de las aplicaciones subidas a Google Play Store. Indicar por orden alfabético. */

SELECT ap.nombreAp, ap.precioAp
FROM aplicacion AS ap, subida AS su
WHERE su.codigoApSub = ap.codigoAp AND nombreTSub = 'Google Play Store'
ORDER BY ap.nombreAp ASC;

/* 9. Código de las aplicaciones descargadas desde China que pertenecen a Amazon Appstore. */

SELECT DISTINCT ap.codigoAp
FROM aplicacion AS Ap,
(SELECT d.codigoApDesc
FROM descarga AS d
WHERE d.nombreTDesc = 'Amazon Appstore' AND d.paisDesc = 'China') AS tablaDesc
WHERE tablaDesc.codigoApDesc = ap.codigoAp;

/* 10. ¿Cuál es la plataforma que tiene más descargas? */

SELECT d.nombreTDesc, COUNT(D.nombreTDesc)
FROM descarga AS d GROUP BY nombreTDesc
ORDER BY COUNT(nombreTDesc) DESC
LIMIT 1;

/* 11. Mostrar los datos de los usuarios cuya dirección contenga la palabra 'Avda'. Es decir, que vivan en una avenida. */

SELECT *
FROM usuario
WHERE direccion LIKE '%Avda%';

/* 12. Mostrar el número de cuenta de los usuarios cuyo nombre empiecen por la letra 'J'. */

SELECT numeroCuenta
FROM usuario
WHERE nombre LIKE 'J%';

/* 13. Las aplicaciones clasificadas en la categoría de 'Social', ¿qué número de descargas tienen? */

SELECT COUNT(d.codigoApDesc) AS descar
FROM clasificacion AS c, descarga AS d
WHERE c.codigoApClas = d.codigoApDesc AND nombreClas = 'Social'
GROUP BY d.codigoApDesc
ORDER BY descar ASC
LIMIT 1;

/* 14. Indicar los códigos de los empleados que desarrollan aplicaciones entre el primer día del año 2018 y el primero de 2019. */

SELECT codigoEmpl
FROM desarrolla
WHERE fechaInicio BETWEEN 1/1/18 AND 1/1/19;

/* 15. ¿Qué empresa y quiénes han participado en la elaboración de la aplicación llamada 'Climb Cave'? */

SELECT DISTINCT empl.nombreEmpl, empr.nombreE
FROM empleado AS empl, empresa AS empr, desarrolla AS des
WHERE des.codigoEmpl=empr.codigoE AND des.dniDesa=empl.dniEmpl AND des.codigoApDesa=
(SELECT codigoAp FROM aplicacion WHERE nombreAp='Climb Cave');