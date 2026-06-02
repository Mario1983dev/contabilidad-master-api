-- MySQL dump 10.13  Distrib 8.0.45, for Win64 (x86_64)
--
-- Host: localhost    Database: contabilidad_master
-- ------------------------------------------------------
-- Server version	8.0.45

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `account_plan_base`
--

DROP TABLE IF EXISTS `account_plan_base`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `account_plan_base` (
  `id` int NOT NULL AUTO_INCREMENT,
  `code` varchar(20) NOT NULL,
  `name` varchar(150) NOT NULL,
  `account_type` enum('ACTIVO','PASIVO','PATRIMONIO','INGRESO','GASTO','RESULTADO') NOT NULL DEFAULT 'ACTIVO',
  `balance_nature` enum('DEBITO','CREDITO') NOT NULL DEFAULT 'DEBITO',
  `parent_code` varchar(20) DEFAULT NULL,
  `level_num` int NOT NULL DEFAULT '1',
  `allows_entries` tinyint(1) NOT NULL DEFAULT '1',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `sort_order` int NOT NULL DEFAULT '0',
  `notes` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_account_plan_base_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=38 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `account_plan_base`
--

LOCK TABLES `account_plan_base` WRITE;
/*!40000 ALTER TABLE `account_plan_base` DISABLE KEYS */;
INSERT INTO `account_plan_base` VALUES (1,'1010101','CAJA','ACTIVO','DEBITO',NULL,1,1,1,10,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-08 18:50:25'),(2,'4010110','VENTAS','INGRESO','CREDITO',NULL,1,1,1,20,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-11 16:23:53'),(3,'4010120','VENTAS EXENTAS','INGRESO','CREDITO',NULL,1,1,1,30,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-11 16:23:53'),(4,'2010925','IVA DEBITO FISCAL','PASIVO','CREDITO',NULL,1,1,1,40,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-11 16:23:53'),(5,'1010802','IVA CREDITO FISCAL','ACTIVO','DEBITO',NULL,1,1,1,50,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-08 18:50:25'),(6,'1010630','MERCADERIA','ACTIVO','DEBITO',NULL,1,1,1,60,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-08 18:50:25'),(7,'1010801','PPM','ACTIVO','DEBITO',NULL,1,1,1,70,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-08 18:50:25'),(8,'30102','CAPITAL','ACTIVO','DEBITO',NULL,1,1,1,80,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-06-02 21:15:06'),(9,'30101','CAPITAL SOCIAL','PATRIMONIO','CREDITO',NULL,1,1,1,90,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-11 16:23:53'),(10,'2010210','CUENTAS POR PAGAR','PASIVO','CREDITO',NULL,1,1,1,100,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-11 16:23:53'),(11,'2010120','VARIOS ACREEDORES','PASIVO','CREDITO',NULL,1,1,1,110,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-11 16:23:53'),(12,'4010601','OTROS INGRESOS','INGRESO','CREDITO',NULL,1,1,1,120,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-11 16:23:53'),(13,'4010890','GASTOS GENERALES','GASTO','DEBITO',NULL,1,1,1,130,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-11 16:23:53'),(14,'4012210','CORRECCION MONETARIA','GASTO','DEBITO',NULL,1,1,1,140,'En hoja aparece como C Monetaria','2026-03-08 18:50:25','2026-03-11 16:23:53'),(15,'30203','PERDIDA Y GANANCIA','RESULTADO','CREDITO',NULL,1,1,1,150,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-11 16:23:53'),(16,'4010701','PERDIDA TRIBUTARIA','GASTO','DEBITO',NULL,1,1,1,160,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-11 16:23:53'),(17,'1010220','RETIROS','ACTIVO','DEBITO',NULL,1,1,1,170,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-08 18:50:25'),(18,'4010220','COSTO DE VENTA','GASTO','DEBITO',NULL,1,1,1,180,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-06-02 18:33:17'),(19,'4010815','ARRIENDOS','GASTO','DEBITO',NULL,1,1,1,190,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-06-02 18:33:17'),(20,'4010810','SUELDOS','GASTO','DEBITO',NULL,1,1,1,200,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-06-02 18:33:17'),(21,'4010822','HONORARIOS','GASTO','DEBITO',NULL,1,1,1,210,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-06-02 18:33:17'),(22,'2010930','RTA 2DA CATG','PASIVO','CREDITO',NULL,1,1,1,220,'Descripcion tal como aparece en hoja','2026-03-08 18:50:25','2026-06-02 18:33:17'),(23,'2010910','IMPUESTO UNICO','PASIVO','CREDITO',NULL,1,1,1,230,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-06-02 18:33:17'),(24,'30202','UTILIDADES POR CAPITALIZAR','PATRIMONIO','CREDITO',NULL,1,1,1,240,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-06-02 18:33:17'),(25,'1020820','MUEBLES Y UTILES','ACTIVO','DEBITO',NULL,1,1,1,250,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-08 18:50:25'),(26,'30601','FDO. REV. CAP. PROPIO','PATRIMONIO','CREDITO',NULL,1,1,1,260,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-06-02 18:33:17'),(27,'2020101','DEPRE. ACUMULADA','PASIVO','CREDITO',NULL,1,1,1,270,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-06-02 18:33:17'),(28,'1010353','VEHICULO','ACTIVO','DEBITO',NULL,1,1,1,280,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-08 18:50:25'),(29,'2020601','FDO UTILID. ACUMULADAS','PATRIMONIO','CREDITO',NULL,1,1,1,290,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-06-02 18:33:17'),(30,'1010310','HERRAMIENTAS','ACTIVO','DEBITO',NULL,1,1,1,300,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-08 18:50:25'),(31,'1020810','MAQUINARIAS','ACTIVO','DEBITO',NULL,1,1,1,310,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-08 18:50:25'),(32,'1010370','PRESTAMO SOLIDARIO','ACTIVO','DEBITO',NULL,1,1,1,320,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-08 18:50:25'),(33,'4012570','IMPTO. RTA. PRIMERA CATG.','GASTO','DEBITO',NULL,1,1,1,330,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-06-02 18:33:17'),(34,'30103','CTA. CAP. SOCIO 1','ACTIVO','DEBITO',NULL,1,1,1,340,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-08 18:50:25'),(35,'30104','CTA. CAP. SOCIO 2','ACTIVO','DEBITO',NULL,1,1,1,350,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-08 18:50:25'),(36,'1020201','GARANTIA ARRIENDO','ACTIVO','DEBITO',NULL,1,1,1,360,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-08 18:50:25'),(37,'4010916','COMPRA EXENTAS','GASTO','DEBITO',NULL,1,1,1,370,'Descripcion tal como aparece en hoja','2026-03-08 18:50:25','2026-06-02 18:33:17');
/*!40000 ALTER TABLE `account_plan_base` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `entry_types`
--

DROP TABLE IF EXISTS `entry_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `entry_types` (
  `id` int NOT NULL AUTO_INCREMENT,
  `code` varchar(20) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `affects_balance` tinyint(1) DEFAULT '1',
  `is_system` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `entry_types`
--

LOCK TABLES `entry_types` WRITE;
/*!40000 ALTER TABLE `entry_types` DISABLE KEYS */;
INSERT INTO `entry_types` VALUES (7,'MANUAL','Asieto Contable','Asiento manual general',1,1,'2026-04-30 20:07:06'),(8,'APERTURA','Apertura','Asiento de apertura de periodo',1,1,'2026-04-30 20:07:06'),(9,'AJUSTE','Ajuste','Ajuste contable',1,1,'2026-04-30 20:07:06'),(10,'REAPERTURA','Reapertura','Reapertura de periodo',1,1,'2026-04-30 20:07:06');
/*!40000 ALTER TABLE `entry_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `master_users`
--

DROP TABLE IF EXISTS `master_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `master_users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(150) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `master_users`
--

LOCK TABLES `master_users` WRITE;
/*!40000 ALTER TABLE `master_users` DISABLE KEYS */;
INSERT INTO `master_users` VALUES (1,'master@solusoft.cl','$2b$10$8j3RMdRFEk6usKtzS08s9OI.6.DoaHBcLhRzsqmMAFg8be.ScI9Aa',1,'2026-02-28 16:39:22');
/*!40000 ALTER TABLE `master_users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-06-02 17:37:19
