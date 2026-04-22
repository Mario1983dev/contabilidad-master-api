-- MySQL dump 10.13  Distrib 8.0.44, for Win64 (x86_64)
--
-- Host: localhost    Database: contabilidad_master
-- ------------------------------------------------------
-- Server version	8.0.44

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
-- Table structure for table `account_mappings`
--

DROP TABLE IF EXISTS `account_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `account_mappings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `company_id` int NOT NULL,
  `mapping_key` varchar(50) NOT NULL,
  `account_id` int NOT NULL,
  `notes` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_account_mappings_company_key` (`company_id`,`mapping_key`),
  KEY `fk_account_mappings_account` (`account_id`),
  CONSTRAINT `fk_account_mappings_account` FOREIGN KEY (`account_id`) REFERENCES `company_accounts` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_account_mappings_company` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `account_mappings`
--

LOCK TABLES `account_mappings` WRITE;
/*!40000 ALTER TABLE `account_mappings` DISABLE KEYS */;
INSERT INTO `account_mappings` VALUES (1,5,'CAJA',164,'','2026-04-03 01:36:07','2026-04-03 01:36:07'),(2,5,'BANCO',164,'','2026-04-03 01:36:38','2026-04-03 01:36:38'),(3,5,'IVA_CREDITO',168,'','2026-04-03 01:36:58','2026-04-03 01:36:58'),(4,5,'IVA_DEBITO',167,'','2026-04-03 01:37:07','2026-04-03 01:37:07'),(5,5,'COMPRAS',169,'','2026-04-03 01:37:28','2026-04-03 01:37:28'),(6,5,'VENTAS',166,'','2026-04-03 01:37:49','2026-04-03 01:37:49'),(7,5,'CLIENTES',169,'','2026-04-03 01:39:14','2026-04-03 01:39:14'),(8,5,'PROVEEDORES',174,'','2026-04-03 01:39:33','2026-04-03 01:39:52'),(9,7,'CAJA',328,'','2026-04-03 22:13:36','2026-04-20 21:41:02'),(10,7,'BANCO',328,'','2026-04-03 22:13:50','2026-04-20 21:41:02'),(11,7,'CLIENTES',328,'','2026-04-03 22:14:00','2026-04-20 21:41:02'),(12,7,'PROVEEDORES',333,'','2026-04-03 22:14:36','2026-04-20 21:41:02'),(13,7,'IVA_CREDITO',332,'','2026-04-03 22:14:54','2026-04-20 21:41:02'),(14,7,'IVA_DEBITO',331,'','2026-04-03 22:15:02','2026-04-20 21:41:02'),(15,7,'VENTAS',329,'','2026-04-03 22:15:13','2026-04-20 21:41:02'),(16,7,'COMPRAS',328,'','2026-04-03 22:15:50','2026-04-20 21:41:02');
/*!40000 ALTER TABLE `account_mappings` ENABLE KEYS */;
UNLOCK TABLES;

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
INSERT INTO `account_plan_base` VALUES (1,'1010101','CAJA','ACTIVO','DEBITO',NULL,1,1,1,10,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-08 18:50:25'),(2,'4010110','VENTAS','INGRESO','CREDITO',NULL,1,1,1,20,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-11 16:23:53'),(3,'4010120','VENTAS EXENTAS','INGRESO','CREDITO',NULL,1,1,1,30,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-11 16:23:53'),(4,'2010925','IVA DEBITO FISCAL','PASIVO','CREDITO',NULL,1,1,1,40,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-11 16:23:53'),(5,'1010802','IVA CREDITO FISCAL','ACTIVO','DEBITO',NULL,1,1,1,50,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-08 18:50:25'),(6,'1010630','MERCADERIA','ACTIVO','DEBITO',NULL,1,1,1,60,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-08 18:50:25'),(7,'1010801','PPM','ACTIVO','DEBITO',NULL,1,1,1,70,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-08 18:50:25'),(8,'30102','CAPITAL PREFERENTE','ACTIVO','DEBITO',NULL,1,1,1,80,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-08 18:50:25'),(9,'30101','CAPITAL SOCIAL','PATRIMONIO','CREDITO',NULL,1,1,1,90,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-11 16:23:53'),(10,'2010210','CUENTAS POR PAGAR','PASIVO','CREDITO',NULL,1,1,1,100,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-11 16:23:53'),(11,'2010120','VARIOS ACREEDORES','PASIVO','CREDITO',NULL,1,1,1,110,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-11 16:23:53'),(12,'4010601','OTROS INGRESOS','INGRESO','CREDITO',NULL,1,1,1,120,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-11 16:23:53'),(13,'4010890','GASTOS GENERALES','GASTO','DEBITO',NULL,1,1,1,130,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-11 16:23:53'),(14,'4012210','CORRECCION MONETARIA','GASTO','DEBITO',NULL,1,1,1,140,'En hoja aparece como C Monetaria','2026-03-08 18:50:25','2026-03-11 16:23:53'),(15,'30203','PERDIDA Y GANANCIA','RESULTADO','CREDITO',NULL,1,1,1,150,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-11 16:23:53'),(16,'4010701','PERDIDA TRIBUTARIA','GASTO','DEBITO',NULL,1,1,1,160,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-11 16:23:53'),(17,'1010220','RETIROS','ACTIVO','DEBITO',NULL,1,1,1,170,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-08 18:50:25'),(18,'4010220','COSTO DE VENTA','ACTIVO','DEBITO',NULL,1,1,1,180,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-08 18:50:25'),(19,'4010815','ARRIENDOS','ACTIVO','DEBITO',NULL,1,1,1,190,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-08 18:50:25'),(20,'4010810','SUELDOS','ACTIVO','DEBITO',NULL,1,1,1,200,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-08 18:50:25'),(21,'4010822','HONORARIOS','ACTIVO','DEBITO',NULL,1,1,1,210,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-08 18:50:25'),(22,'2010930','RTA 2DA CATG','ACTIVO','DEBITO',NULL,1,1,1,220,'Descripcion tal como aparece en hoja','2026-03-08 18:50:25','2026-03-08 18:50:25'),(23,'2010910','IMPUESTO UNICO','ACTIVO','DEBITO',NULL,1,1,1,230,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-08 18:50:25'),(24,'30202','UTILIDADES POR CAPITALIZAR','ACTIVO','DEBITO',NULL,1,1,1,240,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-08 18:50:25'),(25,'1020820','MUEBLES Y UTILES','ACTIVO','DEBITO',NULL,1,1,1,250,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-08 18:50:25'),(26,'30601','FDO. REV. CAP. PROPIO','ACTIVO','DEBITO',NULL,1,1,1,260,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-08 18:50:25'),(27,'2020101','DEPRE. ACUMULADA','ACTIVO','DEBITO',NULL,1,1,1,270,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-08 18:50:25'),(28,'1010353','VEHICULO','ACTIVO','DEBITO',NULL,1,1,1,280,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-08 18:50:25'),(29,'2020601','FDO UTILID. ACUMULADAS','ACTIVO','DEBITO',NULL,1,1,1,290,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-08 18:50:25'),(30,'1010310','HERRAMIENTAS','ACTIVO','DEBITO',NULL,1,1,1,300,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-08 18:50:25'),(31,'1020810','MAQUINARIAS','ACTIVO','DEBITO',NULL,1,1,1,310,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-08 18:50:25'),(32,'1010370','PRESTAMO SOLIDARIO','ACTIVO','DEBITO',NULL,1,1,1,320,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-08 18:50:25'),(33,'4012570','IMPTO. RTA. PRIMERA CATG.','ACTIVO','DEBITO',NULL,1,1,1,330,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-08 18:50:25'),(34,'30103','CTA. CAP. SOCIO 1','ACTIVO','DEBITO',NULL,1,1,1,340,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-08 18:50:25'),(35,'30104','CTA. CAP. SOCIO 2','ACTIVO','DEBITO',NULL,1,1,1,350,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-08 18:50:25'),(36,'1020201','GARANTIA ARRIENDO','ACTIVO','DEBITO',NULL,1,1,1,360,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-08 18:50:25'),(37,'4010916','COMPRA EXENTAS','ACTIVO','DEBITO',NULL,1,1,1,370,'Descripcion tal como aparece en hoja','2026-03-08 18:50:25','2026-03-08 18:50:25');
/*!40000 ALTER TABLE `account_plan_base` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accounting_periods`
--

DROP TABLE IF EXISTS `accounting_periods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `accounting_periods` (
  `id` int NOT NULL AUTO_INCREMENT,
  `company_id` int NOT NULL,
  `year_num` int NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `status` enum('OPEN','CLOSED') NOT NULL DEFAULT 'OPEN',
  `is_current` tinyint(1) NOT NULL DEFAULT '1',
  `notes` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_accounting_periods_company_year` (`company_id`,`year_num`),
  KEY `idx_accounting_periods_company_id` (`company_id`),
  KEY `idx_accounting_periods_status` (`status`),
  CONSTRAINT `fk_accounting_periods_company` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounting_periods`
--

LOCK TABLES `accounting_periods` WRITE;
/*!40000 ALTER TABLE `accounting_periods` DISABLE KEYS */;
INSERT INTO `accounting_periods` VALUES (3,3,2026,'2026-01-01','2026-12-31','OPEN',1,'Periodo inicial creado automaticamente para la empresa Empresa Demo 2 SPA','2026-03-11 21:35:39','2026-03-11 21:35:39'),(5,5,2026,'2026-01-01','2026-12-31','OPEN',1,'Periodo inicial creado automaticamente para la empresa marioempresa','2026-03-21 16:25:42','2026-03-21 16:25:42'),(6,6,2026,'2026-01-01','2026-12-31','OPEN',1,'Periodo inicial creado automaticamente para la empresa prueba','2026-03-25 19:53:24','2026-03-25 19:53:24'),(7,7,2026,'2026-01-01','2026-12-31','OPEN',1,'Periodo inicial creado automaticamente para la empresa prueba7','2026-04-03 21:19:42','2026-04-20 21:41:02'),(8,8,2026,'2026-01-01','2026-12-31','OPEN',1,'Periodo inicial creado automaticamente para la empresa solusoft spa','2026-04-10 20:32:36','2026-04-10 20:32:36');
/*!40000 ALTER TABLE `accounting_periods` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `audit_log`
--

DROP TABLE IF EXISTS `audit_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `audit_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `actor_type` enum('MASTER','OFFICE') NOT NULL,
  `actor_id` int NOT NULL,
  `action` varchar(255) NOT NULL,
  `entity` varchar(100) DEFAULT NULL,
  `entity_id` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_log`
--

LOCK TABLES `audit_log` WRITE;
/*!40000 ALTER TABLE `audit_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `audit_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `companies`
--

DROP TABLE IF EXISTS `companies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `companies` (
  `id` int NOT NULL AUTO_INCREMENT,
  `office_id` int NOT NULL,
  `name` varchar(150) NOT NULL,
  `legal_name` varchar(200) DEFAULT NULL,
  `business_type` varchar(100) DEFAULT NULL,
  `business_name` varchar(200) DEFAULT NULL,
  `rut` varchar(20) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `commune` varchar(100) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `region_name` varchar(100) DEFAULT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `status` enum('active','inactive') NOT NULL DEFAULT 'active',
  `notes` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_companies_office` (`office_id`),
  KEY `idx_companies_status` (`status`),
  KEY `idx_companies_office_id` (`office_id`),
  CONSTRAINT `fk_companies_office` FOREIGN KEY (`office_id`) REFERENCES `offices` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `companies`
--

LOCK TABLES `companies` WRITE;
/*!40000 ALTER TABLE `companies` DISABLE KEYS */;
INSERT INTO `companies` VALUES (3,1,'Empresa Demo 2 SPA','Empresa Demo 2 SpA','Servicios',NULL,'76999999-1','Av. Secundaria 456','Puente Alto','Santiago','Metropolitana','+56911112222','demo2@empresa.cl','active','Segunda empresa de prueba','2026-03-11 21:35:39','2026-03-11 23:52:46'),(5,4,'marioempresa1',NULL,NULL,NULL,'156338028',NULL,NULL,NULL,NULL,NULL,NULL,'active',NULL,'2026-03-21 16:25:42','2026-03-21 16:39:02'),(6,4,'prueba','prueba','prueba',NULL,'1-9','pruab','puente alto','santiago','metropolitana','35666666','prueba@gmail.com','active',NULL,'2026-03-25 19:53:24','2026-03-25 19:53:24'),(7,7,'prueba71','prueba7','prueba7',NULL,'76845873-2','prueba7','puente alto','santiago','mwreopolitana','457777','prueba7@gmail.com','active',NULL,'2026-04-03 21:19:42','2026-04-20 21:19:36'),(8,9,'solusoft spa','solusoft spa','prueba1',NULL,'77094826-6','pto punta arenas','puente alto','santiago','metropolitana','3545666','solusoftspa@gmail.com','active','prueba','2026-04-10 20:32:36','2026-04-10 20:33:01');
/*!40000 ALTER TABLE `companies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `company_accounts`
--

DROP TABLE IF EXISTS `company_accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `company_accounts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `company_id` int NOT NULL,
  `code` varchar(20) NOT NULL,
  `name` varchar(150) NOT NULL,
  `account_type` enum('ACTIVO','PASIVO','PATRIMONIO','INGRESO','GASTO','RESULTADO') NOT NULL,
  `balance_nature` enum('DEBITO','CREDITO') NOT NULL,
  `parent_code` varchar(20) DEFAULT NULL,
  `level_num` int NOT NULL DEFAULT '1',
  `allows_entries` tinyint(1) NOT NULL DEFAULT '1',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `sort_order` int NOT NULL DEFAULT '0',
  `notes` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_company_accounts_company_code` (`company_id`,`code`),
  KEY `idx_company_accounts_company` (`company_id`),
  KEY `idx_company_accounts_company_id` (`company_id`),
  KEY `idx_company_accounts_active` (`is_active`)
) ENGINE=InnoDB AUTO_INCREMENT=457 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `company_accounts`
--

LOCK TABLES `company_accounts` WRITE;
/*!40000 ALTER TABLE `company_accounts` DISABLE KEYS */;
INSERT INTO `company_accounts` VALUES (64,3,'1010101','CAJA','ACTIVO','DEBITO',NULL,1,1,1,10,'Extraido de imagen enviada por usuario','2026-03-11 21:35:39','2026-03-11 21:35:39'),(65,3,'4010110','VENTAS','INGRESO','CREDITO',NULL,1,1,1,20,'Extraido de imagen enviada por usuario','2026-03-11 21:35:39','2026-03-11 21:35:39'),(66,3,'4010120','VENTAS EXENTAS','INGRESO','CREDITO',NULL,1,1,1,30,'Extraido de imagen enviada por usuario','2026-03-11 21:35:39','2026-03-11 21:35:39'),(67,3,'2010925','IVA DEBITO FISCAL','PASIVO','CREDITO',NULL,1,1,1,40,'Extraido de imagen enviada por usuario','2026-03-11 21:35:39','2026-03-11 21:35:39'),(68,3,'1010802','IVA CREDITO FISCAL','ACTIVO','DEBITO',NULL,1,1,1,50,'Extraido de imagen enviada por usuario','2026-03-11 21:35:39','2026-03-11 21:35:39'),(69,3,'1010630','MERCADERIA','ACTIVO','DEBITO',NULL,1,1,1,60,'Extraido de imagen enviada por usuario','2026-03-11 21:35:39','2026-03-11 21:35:39'),(70,3,'1010801','PPM','ACTIVO','DEBITO',NULL,1,1,1,70,'Extraido de imagen enviada por usuario','2026-03-11 21:35:39','2026-03-11 21:35:39'),(71,3,'30102','CAPITAL PREFERENTE','ACTIVO','DEBITO',NULL,1,1,1,80,'Extraido de imagen enviada por usuario','2026-03-11 21:35:39','2026-03-11 21:35:39'),(72,3,'30101','CAPITAL SOCIAL','PATRIMONIO','CREDITO',NULL,1,1,1,90,'Extraido de imagen enviada por usuario','2026-03-11 21:35:39','2026-03-11 21:35:39'),(73,3,'2010210','CUENTAS POR PAGAR','PASIVO','CREDITO',NULL,1,1,1,100,'Extraido de imagen enviada por usuario','2026-03-11 21:35:39','2026-03-11 21:35:39'),(74,3,'2010120','VARIOS ACREEDORES','PASIVO','CREDITO',NULL,1,1,1,110,'Extraido de imagen enviada por usuario','2026-03-11 21:35:39','2026-03-11 21:35:39'),(75,3,'4010601','OTROS INGRESOS','INGRESO','CREDITO',NULL,1,1,1,120,'Extraido de imagen enviada por usuario','2026-03-11 21:35:39','2026-03-11 21:35:39'),(76,3,'4010890','GASTOS GENERALES','GASTO','DEBITO',NULL,1,1,1,130,'Extraido de imagen enviada por usuario','2026-03-11 21:35:39','2026-03-11 21:35:39'),(77,3,'4012210','CORRECCION MONETARIA','GASTO','DEBITO',NULL,1,1,1,140,'En hoja aparece como C Monetaria','2026-03-11 21:35:39','2026-03-11 21:35:39'),(78,3,'30203','PERDIDA Y GANANCIA','RESULTADO','CREDITO',NULL,1,1,1,150,'Extraido de imagen enviada por usuario','2026-03-11 21:35:39','2026-03-11 21:35:39'),(79,3,'4010701','PERDIDA TRIBUTARIA','GASTO','DEBITO',NULL,1,1,1,160,'Extraido de imagen enviada por usuario','2026-03-11 21:35:39','2026-03-11 21:35:39'),(80,3,'1010220','RETIROS','ACTIVO','DEBITO',NULL,1,1,1,170,'Extraido de imagen enviada por usuario','2026-03-11 21:35:39','2026-03-11 21:35:39'),(81,3,'4010220','COSTO DE VENTA','ACTIVO','DEBITO',NULL,1,1,1,180,'Extraido de imagen enviada por usuario','2026-03-11 21:35:39','2026-03-11 21:35:39'),(82,3,'4010815','ARRIENDOS','ACTIVO','DEBITO',NULL,1,1,1,190,'Extraido de imagen enviada por usuario','2026-03-11 21:35:39','2026-03-11 21:35:39'),(83,3,'4010810','SUELDOS','ACTIVO','DEBITO',NULL,1,1,1,200,'Extraido de imagen enviada por usuario','2026-03-11 21:35:39','2026-03-11 21:35:39'),(84,3,'4010822','HONORARIOS','ACTIVO','DEBITO',NULL,1,1,1,210,'Extraido de imagen enviada por usuario','2026-03-11 21:35:39','2026-03-11 21:35:39'),(85,3,'2010930','RTA 2DA CATG','ACTIVO','DEBITO',NULL,1,1,1,220,'Descripcion tal como aparece en hoja','2026-03-11 21:35:39','2026-03-11 21:35:39'),(86,3,'2010910','IMPUESTO UNICO','ACTIVO','DEBITO',NULL,1,1,1,230,'Extraido de imagen enviada por usuario','2026-03-11 21:35:39','2026-03-11 21:35:39'),(87,3,'30202','UTILIDADES POR CAPITALIZAR','ACTIVO','DEBITO',NULL,1,1,1,240,'Extraido de imagen enviada por usuario','2026-03-11 21:35:39','2026-03-11 21:35:39'),(88,3,'1020820','MUEBLES Y UTILES','ACTIVO','DEBITO',NULL,1,1,1,250,'Extraido de imagen enviada por usuario','2026-03-11 21:35:39','2026-03-11 21:35:39'),(89,3,'30601','FDO. REV. CAP. PROPIO','ACTIVO','DEBITO',NULL,1,1,1,260,'Extraido de imagen enviada por usuario','2026-03-11 21:35:39','2026-03-11 21:35:39'),(90,3,'2020101','DEPRE. ACUMULADA','ACTIVO','DEBITO',NULL,1,1,1,270,'Extraido de imagen enviada por usuario','2026-03-11 21:35:39','2026-03-11 21:35:39'),(91,3,'1010353','VEHICULO','ACTIVO','DEBITO',NULL,1,1,1,280,'Extraido de imagen enviada por usuario','2026-03-11 21:35:39','2026-03-11 21:35:39'),(92,3,'2020601','FDO UTILID. ACUMULADAS','ACTIVO','DEBITO',NULL,1,1,1,290,'Extraido de imagen enviada por usuario','2026-03-11 21:35:39','2026-03-11 21:35:39'),(93,3,'1010310','HERRAMIENTAS','ACTIVO','DEBITO',NULL,1,1,1,300,'Extraido de imagen enviada por usuario','2026-03-11 21:35:39','2026-03-11 21:35:39'),(94,3,'1020810','MAQUINARIAS','ACTIVO','DEBITO',NULL,1,1,1,310,'Extraido de imagen enviada por usuario','2026-03-11 21:35:39','2026-03-11 21:35:39'),(95,3,'1010370','PRESTAMO SOLIDARIO','ACTIVO','DEBITO',NULL,1,1,1,320,'Extraido de imagen enviada por usuario','2026-03-11 21:35:39','2026-03-11 21:35:39'),(96,3,'4012570','IMPTO. RTA. PRIMERA CATG.','ACTIVO','DEBITO',NULL,1,1,1,330,'Extraido de imagen enviada por usuario','2026-03-11 21:35:39','2026-03-11 21:35:39'),(97,3,'30103','CTA. CAP. SOCIO 1','ACTIVO','DEBITO',NULL,1,1,1,340,'Extraido de imagen enviada por usuario','2026-03-11 21:35:39','2026-03-11 21:35:39'),(98,3,'30104','CTA. CAP. SOCIO 2','ACTIVO','DEBITO',NULL,1,1,1,350,'Extraido de imagen enviada por usuario','2026-03-11 21:35:39','2026-03-11 21:35:39'),(99,3,'1020201','GARANTIA ARRIENDO','ACTIVO','DEBITO',NULL,1,1,1,360,'Extraido de imagen enviada por usuario','2026-03-11 21:35:39','2026-03-11 21:35:39'),(100,3,'4010916','COMPRA EXENTAS','ACTIVO','DEBITO',NULL,1,1,1,370,'Descripcion tal como aparece en hoja','2026-03-11 21:35:39','2026-03-11 21:35:39'),(164,5,'1010101','CAJA','ACTIVO','DEBITO',NULL,1,1,1,10,'Extraido de imagen enviada por usuario','2026-03-21 16:25:42','2026-03-21 16:25:42'),(165,5,'4010110','VENTAS','INGRESO','CREDITO',NULL,1,1,1,20,'Extraido de imagen enviada por usuario','2026-03-21 16:25:42','2026-03-21 16:25:42'),(166,5,'4010120','VENTAS EXENTAS','INGRESO','CREDITO',NULL,1,1,1,30,'Extraido de imagen enviada por usuario','2026-03-21 16:25:42','2026-03-21 16:25:42'),(167,5,'2010925','IVA DEBITO FISCAL','PASIVO','CREDITO',NULL,1,1,1,40,'Extraido de imagen enviada por usuario','2026-03-21 16:25:42','2026-03-21 16:25:42'),(168,5,'1010802','IVA CREDITO FISCAL','ACTIVO','DEBITO',NULL,1,1,1,50,'Extraido de imagen enviada por usuario','2026-03-21 16:25:42','2026-03-21 16:25:42'),(169,5,'1010630','MERCADERIA','ACTIVO','DEBITO',NULL,1,1,1,60,'Extraido de imagen enviada por usuario','2026-03-21 16:25:42','2026-03-21 16:25:42'),(170,5,'1010801','PPM','ACTIVO','DEBITO',NULL,1,1,1,70,'Extraido de imagen enviada por usuario','2026-03-21 16:25:42','2026-03-21 16:25:42'),(171,5,'30102','CAPITAL PREFERENTE','ACTIVO','DEBITO',NULL,1,1,1,80,'Extraido de imagen enviada por usuario','2026-03-21 16:25:42','2026-03-21 16:25:42'),(172,5,'30101','CAPITAL SOCIAL','PATRIMONIO','CREDITO',NULL,1,1,1,90,'Extraido de imagen enviada por usuario','2026-03-21 16:25:42','2026-03-21 16:25:42'),(173,5,'2010210','CUENTAS POR PAGAR','PASIVO','CREDITO',NULL,1,1,1,100,'Extraido de imagen enviada por usuario','2026-03-21 16:25:42','2026-03-21 16:25:42'),(174,5,'2010120','VARIOS ACREEDORES','PASIVO','CREDITO',NULL,1,1,1,110,'Extraido de imagen enviada por usuario','2026-03-21 16:25:42','2026-03-21 16:25:42'),(175,5,'4010601','OTROS INGRESOS','INGRESO','CREDITO',NULL,1,1,1,120,'Extraido de imagen enviada por usuario','2026-03-21 16:25:42','2026-03-21 16:25:42'),(176,5,'4010890','GASTOS GENERALES','GASTO','DEBITO',NULL,1,1,1,130,'Extraido de imagen enviada por usuario','2026-03-21 16:25:42','2026-03-21 16:25:42'),(177,5,'4012210','CORRECCION MONETARIA','GASTO','DEBITO',NULL,1,1,1,140,'En hoja aparece como C Monetaria','2026-03-21 16:25:42','2026-03-21 16:25:42'),(178,5,'30203','PERDIDA Y GANANCIA','RESULTADO','CREDITO',NULL,1,1,1,150,'Extraido de imagen enviada por usuario','2026-03-21 16:25:42','2026-03-21 16:25:42'),(179,5,'4010701','PERDIDA TRIBUTARIA','GASTO','DEBITO',NULL,1,1,1,160,'Extraido de imagen enviada por usuario','2026-03-21 16:25:42','2026-03-21 16:25:42'),(180,5,'1010220','RETIROS','ACTIVO','DEBITO',NULL,1,1,1,170,'Extraido de imagen enviada por usuario','2026-03-21 16:25:42','2026-03-21 16:25:42'),(181,5,'4010220','COSTO DE VENTA','ACTIVO','DEBITO',NULL,1,1,1,180,'Extraido de imagen enviada por usuario','2026-03-21 16:25:42','2026-03-21 16:25:42'),(182,5,'4010815','ARRIENDOS','ACTIVO','DEBITO',NULL,1,1,1,190,'Extraido de imagen enviada por usuario','2026-03-21 16:25:42','2026-03-21 16:25:42'),(183,5,'4010810','SUELDOS','ACTIVO','DEBITO',NULL,1,1,1,200,'Extraido de imagen enviada por usuario','2026-03-21 16:25:42','2026-03-21 16:25:42'),(184,5,'4010822','HONORARIOS','ACTIVO','DEBITO',NULL,1,1,1,210,'Extraido de imagen enviada por usuario','2026-03-21 16:25:42','2026-03-21 16:25:42'),(185,5,'2010930','RTA 2DA CATG','ACTIVO','DEBITO',NULL,1,1,1,220,'Descripcion tal como aparece en hoja','2026-03-21 16:25:42','2026-03-21 16:25:42'),(186,5,'2010910','IMPUESTO UNICO','ACTIVO','DEBITO',NULL,1,1,1,230,'Extraido de imagen enviada por usuario','2026-03-21 16:25:42','2026-03-21 16:25:42'),(187,5,'30202','UTILIDADES POR CAPITALIZAR','ACTIVO','DEBITO',NULL,1,1,1,240,'Extraido de imagen enviada por usuario','2026-03-21 16:25:42','2026-03-21 16:25:42'),(188,5,'1020820','MUEBLES Y UTILES','ACTIVO','DEBITO',NULL,1,1,1,250,'Extraido de imagen enviada por usuario','2026-03-21 16:25:42','2026-03-21 16:25:42'),(189,5,'30601','FDO. REV. CAP. PROPIO','ACTIVO','DEBITO',NULL,1,1,1,260,'Extraido de imagen enviada por usuario','2026-03-21 16:25:42','2026-03-21 16:25:42'),(190,5,'2020101','DEPRE. ACUMULADA','ACTIVO','DEBITO',NULL,1,1,1,270,'Extraido de imagen enviada por usuario','2026-03-21 16:25:42','2026-03-21 16:25:42'),(191,5,'1010353','VEHICULO','ACTIVO','DEBITO',NULL,1,1,1,280,'Extraido de imagen enviada por usuario','2026-03-21 16:25:42','2026-03-21 16:25:42'),(192,5,'2020601','FDO UTILID. ACUMULADAS','ACTIVO','DEBITO',NULL,1,1,1,290,'Extraido de imagen enviada por usuario','2026-03-21 16:25:42','2026-03-21 16:25:42'),(193,5,'1010310','HERRAMIENTAS','ACTIVO','DEBITO',NULL,1,1,1,300,'Extraido de imagen enviada por usuario','2026-03-21 16:25:42','2026-03-21 16:25:42'),(194,5,'1020810','MAQUINARIAS','ACTIVO','DEBITO',NULL,1,1,1,310,'Extraido de imagen enviada por usuario','2026-03-21 16:25:42','2026-03-21 16:25:42'),(195,5,'1010370','PRESTAMO SOLIDARIO','ACTIVO','DEBITO',NULL,1,1,1,320,'Extraido de imagen enviada por usuario','2026-03-21 16:25:42','2026-03-21 16:25:42'),(196,5,'4012570','IMPTO. RTA. PRIMERA CATG.','ACTIVO','DEBITO',NULL,1,1,1,330,'Extraido de imagen enviada por usuario','2026-03-21 16:25:42','2026-03-21 16:25:42'),(197,5,'30103','CTA. CAP. SOCIO 1','ACTIVO','DEBITO',NULL,1,1,1,340,'Extraido de imagen enviada por usuario','2026-03-21 16:25:42','2026-03-21 16:25:42'),(198,5,'30104','CTA. CAP. SOCIO 2','ACTIVO','DEBITO',NULL,1,1,1,350,'Extraido de imagen enviada por usuario','2026-03-21 16:25:42','2026-03-21 16:25:42'),(199,5,'1020201','GARANTIA ARRIENDO','ACTIVO','DEBITO',NULL,1,1,1,360,'Extraido de imagen enviada por usuario','2026-03-21 16:25:42','2026-03-21 16:25:42'),(200,5,'4010916','COMPRA EXENTAS','ACTIVO','DEBITO',NULL,1,1,1,370,'Descripcion tal como aparece en hoja','2026-03-21 16:25:42','2026-03-21 16:25:42'),(201,6,'1010101','CAJA','ACTIVO','DEBITO',NULL,1,1,1,10,'Extraido de imagen enviada por usuario','2026-03-25 19:53:24','2026-03-25 19:53:24'),(202,6,'4010110','VENTAS','INGRESO','CREDITO',NULL,1,1,1,20,'Extraido de imagen enviada por usuario','2026-03-25 19:53:24','2026-03-25 19:53:24'),(203,6,'4010120','VENTAS EXENTAS','INGRESO','CREDITO',NULL,1,1,1,30,'Extraido de imagen enviada por usuario','2026-03-25 19:53:24','2026-03-25 19:53:24'),(204,6,'2010925','IVA DEBITO FISCAL','PASIVO','CREDITO',NULL,1,1,1,40,'Extraido de imagen enviada por usuario','2026-03-25 19:53:24','2026-03-25 19:53:24'),(205,6,'1010802','IVA CREDITO FISCAL','ACTIVO','DEBITO',NULL,1,1,1,50,'Extraido de imagen enviada por usuario','2026-03-25 19:53:24','2026-03-25 19:53:24'),(206,6,'1010630','MERCADERIA','ACTIVO','DEBITO',NULL,1,1,1,60,'Extraido de imagen enviada por usuario','2026-03-25 19:53:24','2026-03-25 19:53:24'),(207,6,'1010801','PPM','ACTIVO','DEBITO',NULL,1,1,1,70,'Extraido de imagen enviada por usuario','2026-03-25 19:53:24','2026-03-25 19:53:24'),(208,6,'30102','CAPITAL PREFERENTE','ACTIVO','DEBITO',NULL,1,1,1,80,'Extraido de imagen enviada por usuario','2026-03-25 19:53:24','2026-03-25 19:53:24'),(209,6,'30101','CAPITAL SOCIAL','PATRIMONIO','CREDITO',NULL,1,1,1,90,'Extraido de imagen enviada por usuario','2026-03-25 19:53:24','2026-03-25 19:53:24'),(210,6,'2010210','CUENTAS POR PAGAR','PASIVO','CREDITO',NULL,1,1,1,100,'Extraido de imagen enviada por usuario','2026-03-25 19:53:24','2026-03-25 19:53:24'),(211,6,'2010120','VARIOS ACREEDORES','PASIVO','CREDITO',NULL,1,1,1,110,'Extraido de imagen enviada por usuario','2026-03-25 19:53:24','2026-03-25 19:53:24'),(212,6,'4010601','OTROS INGRESOS','INGRESO','CREDITO',NULL,1,1,1,120,'Extraido de imagen enviada por usuario','2026-03-25 19:53:24','2026-03-25 19:53:24'),(213,6,'4010890','GASTOS GENERALES','GASTO','DEBITO',NULL,1,1,1,130,'Extraido de imagen enviada por usuario','2026-03-25 19:53:24','2026-03-25 19:53:24'),(214,6,'4012210','CORRECCION MONETARIA','GASTO','DEBITO',NULL,1,1,1,140,'En hoja aparece como C Monetaria','2026-03-25 19:53:24','2026-03-25 19:53:24'),(215,6,'30203','PERDIDA Y GANANCIA','RESULTADO','CREDITO',NULL,1,1,1,150,'Extraido de imagen enviada por usuario','2026-03-25 19:53:24','2026-03-25 19:53:24'),(216,6,'4010701','PERDIDA TRIBUTARIA','GASTO','DEBITO',NULL,1,1,1,160,'Extraido de imagen enviada por usuario','2026-03-25 19:53:24','2026-03-25 19:53:24'),(217,6,'1010220','RETIROS','ACTIVO','DEBITO',NULL,1,1,1,170,'Extraido de imagen enviada por usuario','2026-03-25 19:53:24','2026-03-25 19:53:24'),(218,6,'4010220','COSTO DE VENTA','ACTIVO','DEBITO',NULL,1,1,1,180,'Extraido de imagen enviada por usuario','2026-03-25 19:53:24','2026-03-25 19:53:24'),(219,6,'4010815','ARRIENDOS','ACTIVO','DEBITO',NULL,1,1,1,190,'Extraido de imagen enviada por usuario','2026-03-25 19:53:24','2026-03-25 19:53:24'),(220,6,'4010810','SUELDOS','ACTIVO','DEBITO',NULL,1,1,1,200,'Extraido de imagen enviada por usuario','2026-03-25 19:53:24','2026-03-25 19:53:24'),(221,6,'4010822','HONORARIOS','ACTIVO','DEBITO',NULL,1,1,1,210,'Extraido de imagen enviada por usuario','2026-03-25 19:53:24','2026-03-25 19:53:24'),(222,6,'2010930','RTA 2DA CATG','ACTIVO','DEBITO',NULL,1,1,1,220,'Descripcion tal como aparece en hoja','2026-03-25 19:53:24','2026-03-25 19:53:24'),(223,6,'2010910','IMPUESTO UNICO','ACTIVO','DEBITO',NULL,1,1,1,230,'Extraido de imagen enviada por usuario','2026-03-25 19:53:24','2026-03-25 19:53:24'),(224,6,'30202','UTILIDADES POR CAPITALIZAR','ACTIVO','DEBITO',NULL,1,1,1,240,'Extraido de imagen enviada por usuario','2026-03-25 19:53:24','2026-03-25 19:53:24'),(225,6,'1020820','MUEBLES Y UTILES','ACTIVO','DEBITO',NULL,1,1,1,250,'Extraido de imagen enviada por usuario','2026-03-25 19:53:24','2026-03-25 19:53:24'),(226,6,'30601','FDO. REV. CAP. PROPIO','ACTIVO','DEBITO',NULL,1,1,1,260,'Extraido de imagen enviada por usuario','2026-03-25 19:53:24','2026-03-25 19:53:24'),(227,6,'2020101','DEPRE. ACUMULADA','ACTIVO','DEBITO',NULL,1,1,1,270,'Extraido de imagen enviada por usuario','2026-03-25 19:53:24','2026-03-25 19:53:24'),(228,6,'1010353','VEHICULO','ACTIVO','DEBITO',NULL,1,1,1,280,'Extraido de imagen enviada por usuario','2026-03-25 19:53:24','2026-03-25 19:53:24'),(229,6,'2020601','FDO UTILID. ACUMULADAS','ACTIVO','DEBITO',NULL,1,1,1,290,'Extraido de imagen enviada por usuario','2026-03-25 19:53:24','2026-03-25 19:53:24'),(230,6,'1010310','HERRAMIENTAS','ACTIVO','DEBITO',NULL,1,1,1,300,'Extraido de imagen enviada por usuario','2026-03-25 19:53:24','2026-03-25 19:53:24'),(231,6,'1020810','MAQUINARIAS','ACTIVO','DEBITO',NULL,1,1,1,310,'Extraido de imagen enviada por usuario','2026-03-25 19:53:24','2026-03-25 19:53:24'),(232,6,'1010370','PRESTAMO SOLIDARIO','ACTIVO','DEBITO',NULL,1,1,1,320,'Extraido de imagen enviada por usuario','2026-03-25 19:53:24','2026-03-25 19:53:24'),(233,6,'4012570','IMPTO. RTA. PRIMERA CATG.','ACTIVO','DEBITO',NULL,1,1,1,330,'Extraido de imagen enviada por usuario','2026-03-25 19:53:24','2026-03-25 19:53:24'),(234,6,'30103','CTA. CAP. SOCIO 1','ACTIVO','DEBITO',NULL,1,1,1,340,'Extraido de imagen enviada por usuario','2026-03-25 19:53:24','2026-03-25 19:53:24'),(235,6,'30104','CTA. CAP. SOCIO 2','ACTIVO','DEBITO',NULL,1,1,1,350,'Extraido de imagen enviada por usuario','2026-03-25 19:53:24','2026-03-25 19:53:24'),(236,6,'1020201','GARANTIA ARRIENDO','ACTIVO','DEBITO',NULL,1,1,1,360,'Extraido de imagen enviada por usuario','2026-03-25 19:53:24','2026-03-25 19:53:24'),(237,6,'4010916','COMPRA EXENTAS','ACTIVO','DEBITO',NULL,1,1,1,370,'Descripcion tal como aparece en hoja','2026-03-25 19:53:24','2026-03-25 19:53:24'),(264,1,'1010101','CAJA','ACTIVO','DEBITO',NULL,1,1,1,10,'Extraido de imagen enviada por usuario','2026-03-26 18:07:19','2026-03-26 18:07:19'),(265,1,'4010110','VENTAS','INGRESO','CREDITO',NULL,1,1,1,20,'Extraido de imagen enviada por usuario','2026-03-26 18:07:19','2026-03-26 18:07:19'),(266,1,'4010120','VENTAS EXENTAS','INGRESO','CREDITO',NULL,1,1,1,30,'Extraido de imagen enviada por usuario','2026-03-26 18:07:19','2026-03-26 18:07:19'),(267,1,'2010925','IVA DEBITO FISCAL','PASIVO','CREDITO',NULL,1,1,1,40,'Extraido de imagen enviada por usuario','2026-03-26 18:07:19','2026-03-26 18:07:19'),(268,1,'1010802','IVA CREDITO FISCAL','ACTIVO','DEBITO',NULL,1,1,1,50,'Extraido de imagen enviada por usuario','2026-03-26 18:07:19','2026-03-26 18:07:19'),(269,1,'1010630','MERCADERIA','ACTIVO','DEBITO',NULL,1,1,1,60,'Extraido de imagen enviada por usuario','2026-03-26 18:07:19','2026-03-26 18:07:19'),(270,1,'1010801','PPM','ACTIVO','DEBITO',NULL,1,1,1,70,'Extraido de imagen enviada por usuario','2026-03-26 18:07:19','2026-03-26 18:07:19'),(271,1,'30102','CAPITAL PREFERENTE','ACTIVO','DEBITO',NULL,1,1,1,80,'Extraido de imagen enviada por usuario','2026-03-26 18:07:19','2026-03-26 18:07:19'),(272,1,'30101','CAPITAL SOCIAL','PATRIMONIO','CREDITO',NULL,1,1,1,90,'Extraido de imagen enviada por usuario','2026-03-26 18:07:19','2026-03-26 18:07:19'),(273,1,'2010210','CUENTAS POR PAGAR','PASIVO','CREDITO',NULL,1,1,1,100,'Extraido de imagen enviada por usuario','2026-03-26 18:07:19','2026-03-26 18:07:19'),(274,1,'2010120','VARIOS ACREEDORES','PASIVO','CREDITO',NULL,1,1,1,110,'Extraido de imagen enviada por usuario','2026-03-26 18:07:19','2026-03-26 18:07:19'),(275,1,'4010601','OTROS INGRESOS','INGRESO','CREDITO',NULL,1,1,1,120,'Extraido de imagen enviada por usuario','2026-03-26 18:07:19','2026-03-26 18:07:19'),(276,1,'4010890','GASTOS GENERALES','GASTO','DEBITO',NULL,1,1,1,130,'Extraido de imagen enviada por usuario','2026-03-26 18:07:19','2026-03-26 18:07:19'),(277,1,'4012210','CORRECCION MONETARIA','GASTO','DEBITO',NULL,1,1,1,140,'En hoja aparece como C Monetaria','2026-03-26 18:07:19','2026-03-26 18:07:19'),(278,1,'30203','PERDIDA Y GANANCIA','RESULTADO','CREDITO',NULL,1,1,1,150,'Extraido de imagen enviada por usuario','2026-03-26 18:07:19','2026-03-26 18:07:19'),(279,1,'4010701','PERDIDA TRIBUTARIA','GASTO','DEBITO',NULL,1,1,1,160,'Extraido de imagen enviada por usuario','2026-03-26 18:07:19','2026-03-26 18:07:19'),(280,1,'1010220','RETIROS','ACTIVO','DEBITO',NULL,1,1,1,170,'Extraido de imagen enviada por usuario','2026-03-26 18:07:19','2026-03-26 18:07:19'),(281,1,'4010220','COSTO DE VENTA','ACTIVO','DEBITO',NULL,1,1,1,180,'Extraido de imagen enviada por usuario','2026-03-26 18:07:19','2026-03-26 18:07:19'),(282,1,'4010815','ARRIENDOS','ACTIVO','DEBITO',NULL,1,1,1,190,'Extraido de imagen enviada por usuario','2026-03-26 18:07:19','2026-03-26 18:07:19'),(283,1,'4010810','SUELDOS','ACTIVO','DEBITO',NULL,1,1,1,200,'Extraido de imagen enviada por usuario','2026-03-26 18:07:19','2026-03-26 18:07:19'),(284,1,'4010822','HONORARIOS','ACTIVO','DEBITO',NULL,1,1,1,210,'Extraido de imagen enviada por usuario','2026-03-26 18:07:19','2026-03-26 18:07:19'),(285,1,'2010930','RTA 2DA CATG','ACTIVO','DEBITO',NULL,1,1,1,220,'Descripcion tal como aparece en hoja','2026-03-26 18:07:19','2026-03-26 18:07:19'),(286,1,'2010910','IMPUESTO UNICO','ACTIVO','DEBITO',NULL,1,1,1,230,'Extraido de imagen enviada por usuario','2026-03-26 18:07:19','2026-03-26 18:07:19'),(287,1,'30202','UTILIDADES POR CAPITALIZAR','ACTIVO','DEBITO',NULL,1,1,1,240,'Extraido de imagen enviada por usuario','2026-03-26 18:07:19','2026-03-26 18:07:19'),(288,1,'1020820','MUEBLES Y UTILES','ACTIVO','DEBITO',NULL,1,1,1,250,'Extraido de imagen enviada por usuario','2026-03-26 18:07:19','2026-03-26 18:07:19'),(289,1,'30601','FDO. REV. CAP. PROPIO','ACTIVO','DEBITO',NULL,1,1,1,260,'Extraido de imagen enviada por usuario','2026-03-26 18:07:19','2026-03-26 18:07:19'),(290,1,'2020101','DEPRE. ACUMULADA','ACTIVO','DEBITO',NULL,1,1,1,270,'Extraido de imagen enviada por usuario','2026-03-26 18:07:19','2026-03-26 18:07:19'),(291,1,'1010353','VEHICULO','ACTIVO','DEBITO',NULL,1,1,1,280,'Extraido de imagen enviada por usuario','2026-03-26 18:07:19','2026-03-26 18:07:19'),(292,1,'2020601','FDO UTILID. ACUMULADAS','ACTIVO','DEBITO',NULL,1,1,1,290,'Extraido de imagen enviada por usuario','2026-03-26 18:07:19','2026-03-26 18:07:19'),(293,1,'1010310','HERRAMIENTAS','ACTIVO','DEBITO',NULL,1,1,1,300,'Extraido de imagen enviada por usuario','2026-03-26 18:07:19','2026-03-26 18:07:19'),(294,1,'1020810','MAQUINARIAS','ACTIVO','DEBITO',NULL,1,1,1,310,'Extraido de imagen enviada por usuario','2026-03-26 18:07:19','2026-03-26 18:07:19'),(295,1,'1010370','PRESTAMO SOLIDARIO','ACTIVO','DEBITO',NULL,1,1,1,320,'Extraido de imagen enviada por usuario','2026-03-26 18:07:19','2026-03-26 18:07:19'),(296,1,'4012570','IMPTO. RTA. PRIMERA CATG.','ACTIVO','DEBITO',NULL,1,1,1,330,'Extraido de imagen enviada por usuario','2026-03-26 18:07:19','2026-03-26 18:07:19'),(297,1,'30103','CTA. CAP. SOCIO 1','ACTIVO','DEBITO',NULL,1,1,1,340,'Extraido de imagen enviada por usuario','2026-03-26 18:07:19','2026-03-26 18:07:19'),(298,1,'30104','CTA. CAP. SOCIO 2','ACTIVO','DEBITO',NULL,1,1,1,350,'Extraido de imagen enviada por usuario','2026-03-26 18:07:19','2026-03-26 18:07:19'),(299,1,'1020201','GARANTIA ARRIENDO','ACTIVO','DEBITO',NULL,1,1,1,360,'Extraido de imagen enviada por usuario','2026-03-26 18:07:19','2026-03-26 18:07:19'),(300,1,'4010916','COMPRA EXENTAS','ACTIVO','DEBITO',NULL,1,1,1,370,'Descripcion tal como aparece en hoja','2026-03-26 18:07:19','2026-03-26 18:07:19'),(327,6,'1010102','prueb','ACTIVO','DEBITO',NULL,1,1,1,1,'ESTAMOS HACIENDO PRUEA','2026-03-27 16:48:53','2026-03-27 16:48:53'),(328,7,'1010101','CAJA','ACTIVO','DEBITO',NULL,1,1,1,10,'Extraido de imagen enviada por usuario','2026-04-03 21:19:42','2026-04-03 21:19:42'),(329,7,'4010110','VENTAS','INGRESO','CREDITO',NULL,1,1,1,20,'Extraido de imagen enviada por usuario','2026-04-03 21:19:42','2026-04-03 21:19:42'),(330,7,'4010120','VENTAS EXENTAS','INGRESO','CREDITO',NULL,1,1,1,30,'Extraido de imagen enviada por usuario','2026-04-03 21:19:42','2026-04-03 21:19:42'),(331,7,'2010925','IVA DEBITO FISCAL','PASIVO','CREDITO',NULL,1,1,1,40,'Extraido de imagen enviada por usuario','2026-04-03 21:19:42','2026-04-03 21:19:42'),(332,7,'1010802','IVA CREDITO FISCAL','ACTIVO','DEBITO',NULL,1,1,1,50,'Extraido de imagen enviada por usuario','2026-04-03 21:19:42','2026-04-03 21:19:42'),(333,7,'1010630','MERCADERIA','ACTIVO','DEBITO',NULL,1,1,1,60,'Extraido de imagen enviada por usuario','2026-04-03 21:19:42','2026-04-03 21:19:42'),(334,7,'1010801','PPM','ACTIVO','DEBITO',NULL,1,1,1,70,'Extraido de imagen enviada por usuario','2026-04-03 21:19:42','2026-04-03 21:19:42'),(335,7,'30102','CAPITAL PREFERENTE','ACTIVO','DEBITO',NULL,1,1,1,80,'Extraido de imagen enviada por usuario','2026-04-03 21:19:42','2026-04-03 21:19:42'),(336,7,'30101','CAPITAL SOCIAL','PATRIMONIO','CREDITO',NULL,1,1,1,90,'Extraido de imagen enviada por usuario','2026-04-03 21:19:42','2026-04-03 21:19:42'),(337,7,'2010210','CUENTAS POR PAGAR','PASIVO','CREDITO',NULL,1,1,1,100,'Extraido de imagen enviada por usuario','2026-04-03 21:19:42','2026-04-03 21:19:42'),(338,7,'2010120','VARIOS ACREEDORES','PASIVO','CREDITO',NULL,1,1,1,110,'Extraido de imagen enviada por usuario','2026-04-03 21:19:42','2026-04-03 21:19:42'),(339,7,'4010601','OTROS INGRESOS','INGRESO','CREDITO',NULL,1,1,1,120,'Extraido de imagen enviada por usuario','2026-04-03 21:19:42','2026-04-03 21:19:42'),(340,7,'4010890','GASTOS GENERALES','GASTO','DEBITO',NULL,1,1,1,130,'Extraido de imagen enviada por usuario','2026-04-03 21:19:42','2026-04-03 21:19:42'),(341,7,'4012210','CORRECCION MONETARIA','GASTO','DEBITO',NULL,1,1,1,140,'En hoja aparece como C Monetaria','2026-04-03 21:19:42','2026-04-03 21:19:42'),(342,7,'30203','PERDIDA Y GANANCIA','RESULTADO','CREDITO',NULL,1,1,1,150,'Extraido de imagen enviada por usuario','2026-04-03 21:19:42','2026-04-03 21:19:42'),(343,7,'4010701','PERDIDA TRIBUTARIA','GASTO','DEBITO',NULL,1,1,1,160,'Extraido de imagen enviada por usuario','2026-04-03 21:19:42','2026-04-03 21:19:42'),(344,7,'1010220','RETIROS','ACTIVO','DEBITO',NULL,1,1,1,170,'Extraido de imagen enviada por usuario','2026-04-03 21:19:42','2026-04-03 21:19:42'),(345,7,'4010220','COSTO DE VENTA','ACTIVO','DEBITO',NULL,1,1,1,180,'Extraido de imagen enviada por usuario','2026-04-03 21:19:42','2026-04-03 21:19:42'),(346,7,'4010815','ARRIENDOS','ACTIVO','DEBITO',NULL,1,1,1,190,'Extraido de imagen enviada por usuario','2026-04-03 21:19:42','2026-04-03 21:19:42'),(347,7,'4010810','SUELDOS','ACTIVO','DEBITO',NULL,1,1,1,200,'Extraido de imagen enviada por usuario','2026-04-03 21:19:42','2026-04-03 21:19:42'),(348,7,'4010822','HONORARIOS','ACTIVO','DEBITO',NULL,1,1,1,210,'Extraido de imagen enviada por usuario','2026-04-03 21:19:42','2026-04-03 21:19:42'),(349,7,'2010930','RTA 2DA CATG','ACTIVO','DEBITO',NULL,1,1,1,220,'Descripcion tal como aparece en hoja','2026-04-03 21:19:42','2026-04-03 21:19:42'),(350,7,'2010910','IMPUESTO UNICO','ACTIVO','DEBITO',NULL,1,1,1,230,'Extraido de imagen enviada por usuario','2026-04-03 21:19:42','2026-04-03 21:19:42'),(351,7,'30202','UTILIDADES POR CAPITALIZAR','ACTIVO','DEBITO',NULL,1,1,1,240,'Extraido de imagen enviada por usuario','2026-04-03 21:19:42','2026-04-03 21:19:42'),(352,7,'1020820','MUEBLES Y UTILES','ACTIVO','DEBITO',NULL,1,1,1,250,'Extraido de imagen enviada por usuario','2026-04-03 21:19:42','2026-04-03 21:19:42'),(353,7,'30601','FDO. REV. CAP. PROPIO','ACTIVO','DEBITO',NULL,1,1,1,260,'Extraido de imagen enviada por usuario','2026-04-03 21:19:42','2026-04-03 21:19:42'),(354,7,'2020101','DEPRE. ACUMULADA','ACTIVO','DEBITO',NULL,1,1,1,270,'Extraido de imagen enviada por usuario','2026-04-03 21:19:42','2026-04-03 21:19:42'),(355,7,'1010353','VEHICULO','ACTIVO','DEBITO',NULL,1,1,1,280,'Extraido de imagen enviada por usuario','2026-04-03 21:19:42','2026-04-03 21:19:42'),(356,7,'2020601','FDO UTILID. ACUMULADAS','ACTIVO','DEBITO',NULL,1,1,1,290,'Extraido de imagen enviada por usuario','2026-04-03 21:19:42','2026-04-03 21:19:42'),(357,7,'1010310','HERRAMIENTAS','ACTIVO','DEBITO',NULL,1,1,1,300,'Extraido de imagen enviada por usuario','2026-04-03 21:19:42','2026-04-03 21:19:42'),(358,7,'1020810','MAQUINARIAS','ACTIVO','DEBITO',NULL,1,1,1,310,'Extraido de imagen enviada por usuario','2026-04-03 21:19:42','2026-04-03 21:19:42'),(359,7,'1010370','PRESTAMO SOLIDARIO','ACTIVO','DEBITO',NULL,1,1,1,320,'Extraido de imagen enviada por usuario','2026-04-03 21:19:42','2026-04-03 21:19:42'),(360,7,'4012570','IMPTO. RTA. PRIMERA CATG.','ACTIVO','DEBITO',NULL,1,1,1,330,'Extraido de imagen enviada por usuario','2026-04-03 21:19:42','2026-04-03 21:19:42'),(361,7,'30103','CTA. CAP. SOCIO 1','ACTIVO','DEBITO',NULL,1,1,1,340,'Extraido de imagen enviada por usuario','2026-04-03 21:19:42','2026-04-03 21:19:42'),(362,7,'30104','CTA. CAP. SOCIO 2','ACTIVO','DEBITO',NULL,1,1,1,350,'Extraido de imagen enviada por usuario','2026-04-03 21:19:42','2026-04-03 21:19:42'),(363,7,'1020201','GARANTIA ARRIENDO','ACTIVO','DEBITO',NULL,1,1,1,360,'Extraido de imagen enviada por usuario','2026-04-03 21:19:42','2026-04-03 21:19:42'),(364,7,'4010916','COMPRA EXENTAS','ACTIVO','DEBITO',NULL,1,1,1,370,'Descripcion tal como aparece en hoja','2026-04-03 21:19:42','2026-04-03 21:19:42'),(391,8,'1010101','CAJA','ACTIVO','DEBITO',NULL,1,1,1,10,'Extraido de imagen enviada por usuario','2026-04-10 20:32:36','2026-04-10 20:32:36'),(392,8,'4010110','VENTAS','INGRESO','CREDITO',NULL,1,1,1,20,'Extraido de imagen enviada por usuario','2026-04-10 20:32:36','2026-04-10 20:32:36'),(393,8,'4010120','VENTAS EXENTAS','INGRESO','CREDITO',NULL,1,1,1,30,'Extraido de imagen enviada por usuario','2026-04-10 20:32:36','2026-04-10 20:32:36'),(394,8,'2010925','IVA DEBITO FISCAL','PASIVO','CREDITO',NULL,1,1,1,40,'Extraido de imagen enviada por usuario','2026-04-10 20:32:36','2026-04-10 20:32:36'),(395,8,'1010802','IVA CREDITO FISCAL','ACTIVO','DEBITO',NULL,1,1,1,50,'Extraido de imagen enviada por usuario','2026-04-10 20:32:36','2026-04-10 20:32:36'),(396,8,'1010630','MERCADERIA','ACTIVO','DEBITO',NULL,1,1,1,60,'Extraido de imagen enviada por usuario','2026-04-10 20:32:36','2026-04-10 20:32:36'),(397,8,'1010801','PPM','ACTIVO','DEBITO',NULL,1,1,1,70,'Extraido de imagen enviada por usuario','2026-04-10 20:32:36','2026-04-10 20:32:36'),(398,8,'30102','CAPITAL PREFERENTE','ACTIVO','DEBITO',NULL,1,1,1,80,'Extraido de imagen enviada por usuario','2026-04-10 20:32:36','2026-04-10 20:32:36'),(399,8,'30101','CAPITAL SOCIAL','PATRIMONIO','CREDITO',NULL,1,1,1,90,'Extraido de imagen enviada por usuario','2026-04-10 20:32:36','2026-04-10 20:32:36'),(400,8,'2010210','CUENTAS POR PAGAR','PASIVO','CREDITO',NULL,1,1,1,100,'Extraido de imagen enviada por usuario','2026-04-10 20:32:36','2026-04-10 20:32:36'),(401,8,'2010120','VARIOS ACREEDORES','PASIVO','CREDITO',NULL,1,1,1,110,'Extraido de imagen enviada por usuario','2026-04-10 20:32:36','2026-04-10 20:32:36'),(402,8,'4010601','OTROS INGRESOS','INGRESO','CREDITO',NULL,1,1,1,120,'Extraido de imagen enviada por usuario','2026-04-10 20:32:36','2026-04-10 20:32:36'),(403,8,'4010890','GASTOS GENERALES','GASTO','DEBITO',NULL,1,1,1,130,'Extraido de imagen enviada por usuario','2026-04-10 20:32:36','2026-04-10 20:32:36'),(404,8,'4012210','CORRECCION MONETARIA','GASTO','DEBITO',NULL,1,1,1,140,'En hoja aparece como C Monetaria','2026-04-10 20:32:36','2026-04-10 20:32:36'),(405,8,'30203','PERDIDA Y GANANCIA','RESULTADO','CREDITO',NULL,1,1,1,150,'Extraido de imagen enviada por usuario','2026-04-10 20:32:36','2026-04-10 20:32:36'),(406,8,'4010701','PERDIDA TRIBUTARIA','GASTO','DEBITO',NULL,1,1,1,160,'Extraido de imagen enviada por usuario','2026-04-10 20:32:36','2026-04-10 20:32:36'),(407,8,'1010220','RETIROS','ACTIVO','DEBITO',NULL,1,1,1,170,'Extraido de imagen enviada por usuario','2026-04-10 20:32:36','2026-04-10 20:32:36'),(408,8,'4010220','COSTO DE VENTA','ACTIVO','DEBITO',NULL,1,1,1,180,'Extraido de imagen enviada por usuario','2026-04-10 20:32:36','2026-04-10 20:32:36'),(409,8,'4010815','ARRIENDOS','ACTIVO','DEBITO',NULL,1,1,1,190,'Extraido de imagen enviada por usuario','2026-04-10 20:32:36','2026-04-10 20:32:36'),(410,8,'4010810','SUELDOS','ACTIVO','DEBITO',NULL,1,1,1,200,'Extraido de imagen enviada por usuario','2026-04-10 20:32:36','2026-04-10 20:32:36'),(411,8,'4010822','HONORARIOS','ACTIVO','DEBITO',NULL,1,1,1,210,'Extraido de imagen enviada por usuario','2026-04-10 20:32:36','2026-04-10 20:32:36'),(412,8,'2010930','RTA 2DA CATG','ACTIVO','DEBITO',NULL,1,1,1,220,'Descripcion tal como aparece en hoja','2026-04-10 20:32:36','2026-04-10 20:32:36'),(413,8,'2010910','IMPUESTO UNICO','ACTIVO','DEBITO',NULL,1,1,1,230,'Extraido de imagen enviada por usuario','2026-04-10 20:32:36','2026-04-10 20:32:36'),(414,8,'30202','UTILIDADES POR CAPITALIZAR','ACTIVO','DEBITO',NULL,1,1,1,240,'Extraido de imagen enviada por usuario','2026-04-10 20:32:36','2026-04-10 20:32:36'),(415,8,'1020820','MUEBLES Y UTILES','ACTIVO','DEBITO',NULL,1,1,1,250,'Extraido de imagen enviada por usuario','2026-04-10 20:32:36','2026-04-10 20:32:36'),(416,8,'30601','FDO. REV. CAP. PROPIO','ACTIVO','DEBITO',NULL,1,1,1,260,'Extraido de imagen enviada por usuario','2026-04-10 20:32:36','2026-04-10 20:32:36'),(417,8,'2020101','DEPRE. ACUMULADA','ACTIVO','DEBITO',NULL,1,1,1,270,'Extraido de imagen enviada por usuario','2026-04-10 20:32:36','2026-04-10 20:32:36'),(418,8,'1010353','VEHICULO','ACTIVO','DEBITO',NULL,1,1,1,280,'Extraido de imagen enviada por usuario','2026-04-10 20:32:36','2026-04-10 20:32:36'),(419,8,'2020601','FDO UTILID. ACUMULADAS','ACTIVO','DEBITO',NULL,1,1,1,290,'Extraido de imagen enviada por usuario','2026-04-10 20:32:36','2026-04-10 20:32:36'),(420,8,'1010310','HERRAMIENTAS','ACTIVO','DEBITO',NULL,1,1,1,300,'Extraido de imagen enviada por usuario','2026-04-10 20:32:36','2026-04-10 20:32:36'),(421,8,'1020810','MAQUINARIAS','ACTIVO','DEBITO',NULL,1,1,1,310,'Extraido de imagen enviada por usuario','2026-04-10 20:32:36','2026-04-10 20:32:36'),(422,8,'1010370','PRESTAMO SOLIDARIO','ACTIVO','DEBITO',NULL,1,1,1,320,'Extraido de imagen enviada por usuario','2026-04-10 20:32:36','2026-04-10 20:32:36'),(423,8,'4012570','IMPTO. RTA. PRIMERA CATG.','ACTIVO','DEBITO',NULL,1,1,1,330,'Extraido de imagen enviada por usuario','2026-04-10 20:32:36','2026-04-10 20:32:36'),(424,8,'30103','CTA. CAP. SOCIO 1','ACTIVO','DEBITO',NULL,1,1,1,340,'Extraido de imagen enviada por usuario','2026-04-10 20:32:36','2026-04-10 20:32:36'),(425,8,'30104','CTA. CAP. SOCIO 2','ACTIVO','DEBITO',NULL,1,1,1,350,'Extraido de imagen enviada por usuario','2026-04-10 20:32:36','2026-04-10 20:32:36'),(426,8,'1020201','GARANTIA ARRIENDO','ACTIVO','DEBITO',NULL,1,1,1,360,'Extraido de imagen enviada por usuario','2026-04-10 20:32:36','2026-04-10 20:32:36'),(427,8,'4010916','COMPRA EXENTAS','ACTIVO','DEBITO',NULL,1,1,1,370,'Descripcion tal como aparece en hoja','2026-04-10 20:32:36','2026-04-10 20:32:36'),(454,8,'4012571','prueba1','ACTIVO','DEBITO',NULL,1,1,1,1,'','2026-04-10 20:34:04','2026-04-10 20:34:04'),(455,7,'4012571','prueba 2','ACTIVO','DEBITO',NULL,1,1,1,1,'probando','2026-04-20 21:17:41','2026-04-20 21:17:41'),(456,7,'4012572','prueb800','ACTIVO','DEBITO',NULL,1,1,1,1,'','2026-04-20 21:41:36','2026-04-20 21:41:36');
/*!40000 ALTER TABLE `company_accounts` ENABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `entry_types`
--

LOCK TABLES `entry_types` WRITE;
/*!40000 ALTER TABLE `entry_types` DISABLE KEYS */;
INSERT INTO `entry_types` VALUES (1,'NORMAL','Asiento Normal','Registro contable habitual',1,0,'2026-04-06 17:34:50'),(2,'APERTURA','Apertura','Asiento de apertura de periodo',1,1,'2026-04-06 17:34:50'),(3,'CIERRE','Cierre','Asiento de cierre de periodo',1,1,'2026-04-06 17:34:50'),(4,'AJUSTE','Ajuste','Correcciones contables',1,0,'2026-04-06 17:34:50'),(5,'REAPERTURA','Reapertura','Reverso de cierre de periodo',1,1,'2026-04-06 17:34:50'),(6,'RECLASIFICACION','Reclasificación','Cambio entre cuentas',1,0,'2026-04-06 17:34:50');
/*!40000 ALTER TABLE `entry_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `journal_entries`
--

DROP TABLE IF EXISTS `journal_entries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `journal_entries` (
  `id` int NOT NULL AUTO_INCREMENT,
  `company_id` int NOT NULL,
  `entry_date` date NOT NULL,
  `entry_type` varchar(50) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `status` varchar(20) DEFAULT 'posted',
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_journal_entries_company` (`company_id`),
  CONSTRAINT `fk_journal_entries_company` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `journal_entries`
--

LOCK TABLES `journal_entries` WRITE;
/*!40000 ALTER TABLE `journal_entries` DISABLE KEYS */;
INSERT INTO `journal_entries` VALUES (6,7,'2026-03-27','MANUAL','PERFEC','0',NULL,'2026-03-27 20:12:29','2026-04-20 21:12:46'),(9,8,'2026-04-10','MANUAL','prueba solusoft','1',NULL,'2026-04-10 21:03:51','2026-04-20 20:28:26'),(10,8,'2026-04-10','MANUAL','prueba 2 solusoft','1',NULL,'2026-04-10 21:15:25','2026-04-20 20:28:26'),(11,8,'2026-04-10','MANUAL','prueba4','1',NULL,'2026-04-10 21:28:28','2026-04-20 20:28:26'),(12,8,'2026-04-10','MANUAL','pruba solusoft','1',NULL,'2026-04-10 21:44:02','2026-04-10 22:25:34'),(13,8,'2026-04-10','MANUAL','aaaa','1',NULL,'2026-04-10 21:45:14','2026-04-10 22:25:34'),(14,8,'2026-04-10','MANUAL','prueba solusoft','1',NULL,'2026-04-10 22:18:41','2026-04-10 22:25:34'),(17,8,'2026-04-11','AJUSTE','PRUEBA ACTUALIZARRR','1',NULL,'2026-04-11 19:59:51','2026-04-11 20:32:41'),(18,8,'2026-04-11','AJUSTE','','1',NULL,'2026-04-11 20:21:08','2026-04-20 20:28:26'),(19,7,'2026-04-20','AJUSTE','prueba completa','0',NULL,'2026-04-20 21:06:33','2026-04-20 21:43:26'),(20,7,'2026-05-20','AJUSTE','prueba completa','1',NULL,'2026-04-20 21:06:33','2026-04-20 21:06:33'),(21,7,'2026-06-20','AJUSTE','prueba completa','1',NULL,'2026-04-20 21:06:33','2026-04-20 21:06:33'),(22,7,'2026-07-20','AJUSTE','prueba completa','1',NULL,'2026-04-20 21:06:33','2026-04-20 21:06:33'),(23,7,'2026-08-20','AJUSTE','prueba completa','1',NULL,'2026-04-20 21:06:33','2026-04-20 21:06:33'),(24,7,'2026-09-20','AJUSTE','prueba completa','1',NULL,'2026-04-20 21:06:33','2026-04-20 21:06:33'),(25,7,'2026-10-20','AJUSTE','prueba completa','1',NULL,'2026-04-20 21:06:33','2026-04-20 21:06:33'),(26,7,'2026-11-20','AJUSTE','prueba completa','1',NULL,'2026-04-20 21:06:33','2026-04-20 21:06:33'),(27,7,'2026-12-20','AJUSTE','prueba completa','1',NULL,'2026-04-20 21:06:33','2026-04-20 21:29:00'),(28,7,'2026-04-20','AJUSTE','','0',NULL,'2026-04-20 21:42:47','2026-04-20 21:43:31');
/*!40000 ALTER TABLE `journal_entries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `journal_entries_backup`
--

DROP TABLE IF EXISTS `journal_entries_backup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `journal_entries_backup` (
  `id` int NOT NULL DEFAULT '0',
  `company_id` int NOT NULL,
  `entry_date` date NOT NULL,
  `entry_type` varchar(50) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `status` varchar(20) DEFAULT 'posted',
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `journal_entries_backup`
--

LOCK TABLES `journal_entries_backup` WRITE;
/*!40000 ALTER TABLE `journal_entries_backup` DISABLE KEYS */;
INSERT INTO `journal_entries_backup` VALUES (6,7,'2026-03-27','MANUAL','PERFEC','posted',NULL,'2026-03-27 20:12:29','2026-04-09 16:12:09'),(9,8,'2026-04-10','MANUAL','prueba solusoft','0',NULL,'2026-04-10 21:03:51','2026-04-10 22:26:33'),(10,8,'2026-04-10','MANUAL','prueba 2 solusoft','0',NULL,'2026-04-10 21:15:25','2026-04-11 20:04:21'),(11,8,'2026-04-10','MANUAL','prueba4','0',NULL,'2026-04-10 21:28:28','2026-04-10 22:26:36'),(12,8,'2026-04-10','MANUAL','pruba solusoft','1',NULL,'2026-04-10 21:44:02','2026-04-10 22:25:34'),(13,8,'2026-04-10','MANUAL','aaaa','1',NULL,'2026-04-10 21:45:14','2026-04-10 22:25:34'),(14,8,'2026-04-10','MANUAL','prueba solusoft','1',NULL,'2026-04-10 22:18:41','2026-04-10 22:25:34'),(17,8,'2026-04-11','AJUSTE','PRUEBA ACTUALIZARRR','1',NULL,'2026-04-11 19:59:51','2026-04-11 20:32:41'),(18,8,'2026-04-11','AJUSTE','','0',NULL,'2026-04-11 20:21:08','2026-04-11 20:21:18');
/*!40000 ALTER TABLE `journal_entries_backup` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `journal_entry_lines`
--

DROP TABLE IF EXISTS `journal_entry_lines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `journal_entry_lines` (
  `id` int NOT NULL AUTO_INCREMENT,
  `entry_id` int NOT NULL,
  `account_id` int NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `debit` decimal(15,2) DEFAULT '0.00',
  `credit` decimal(15,2) DEFAULT '0.00',
  PRIMARY KEY (`id`),
  KEY `idx_journal_entry_lines_entry` (`entry_id`),
  KEY `idx_journal_entry_lines_account` (`account_id`),
  CONSTRAINT `fk_journal_entry_lines_account` FOREIGN KEY (`account_id`) REFERENCES `company_accounts` (`id`),
  CONSTRAINT `fk_journal_entry_lines_entry` FOREIGN KEY (`entry_id`) REFERENCES `journal_entries` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=65 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `journal_entry_lines`
--

LOCK TABLES `journal_entry_lines` WRITE;
/*!40000 ALTER TABLE `journal_entry_lines` DISABLE KEYS */;
INSERT INTO `journal_entry_lines` VALUES (1,6,329,'',100.00,0.00),(2,6,333,'',0.00,100.00),(7,9,393,'',1000.00,0.00),(8,9,391,'',0.00,1000.00),(9,10,391,'',200.00,0.00),(10,10,392,'',0.00,200.00),(11,11,391,'',10000.00,0.00),(12,11,392,'',0.00,10000.00),(13,12,391,'',100000.00,0.00),(14,12,392,'',0.00,100000.00),(19,13,391,'',10000.00,0.00),(20,13,392,'',0.00,10000.00),(21,14,391,'',10000.00,0.00),(22,14,392,'',0.00,10000.00),(27,18,400,'PAGAR',100.00,0.00),(28,18,391,'',0.00,100.00),(35,17,391,'CAJA',1000000.00,0.00),(36,17,392,'VN',0.00,1000000.00),(39,20,328,NULL,10000.00,0.00),(40,20,329,NULL,0.00,10000.00),(41,21,328,NULL,10000.00,0.00),(42,21,329,NULL,0.00,10000.00),(43,22,328,NULL,10000.00,0.00),(44,22,329,NULL,0.00,10000.00),(45,23,328,NULL,10000.00,0.00),(46,23,329,NULL,0.00,10000.00),(49,25,328,NULL,10000.00,0.00),(50,25,329,NULL,0.00,10000.00),(55,24,328,NULL,10000.00,0.00),(56,24,329,NULL,0.00,10000.00),(57,19,328,NULL,10000.00,0.00),(58,19,329,NULL,0.00,10000.00),(59,26,328,NULL,20000.00,0.00),(60,26,329,NULL,0.00,20000.00),(61,28,336,'1010101',10000.00,0.00),(62,28,328,'CAHA',0.00,10000.00),(63,27,328,'',1000.00,0.00),(64,27,329,'',0.00,1000.00);
/*!40000 ALTER TABLE `journal_entry_lines` ENABLE KEYS */;
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

--
-- Table structure for table `office_admins`
--

DROP TABLE IF EXISTS `office_admins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `office_admins` (
  `id` int NOT NULL AUTO_INCREMENT,
  `office_id` int NOT NULL,
  `email` varchar(150) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `username` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_office_admin_login` (`office_id`,`email`),
  CONSTRAINT `fk_office_admin` FOREIGN KEY (`office_id`) REFERENCES `offices` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `office_admins`
--

LOCK TABLES `office_admins` WRITE;
/*!40000 ALTER TABLE `office_admins` DISABLE KEYS */;
INSERT INTO `office_admins` VALUES (1,1,'admin1@admin.local','$2b$10$k/uMAGDFt/is8DGlpYn1B.RiimWBXeQaOqMcgx4pGqTH040YqfgsS',1,'2026-03-09 03:54:50','admin1'),(2,4,'admin4@admin.local','$2b$10$67QkVPCJO2M0.BCDCtvgWeTUE9XLrY248PxzriAyV44Se.X7DNIzC',1,'2026-03-14 19:58:40','admin4'),(3,5,'admin5@admin.local','$2b$10$2HCkK.YzHURYj3RdTbLvCuOTrb9sOujx/.L/LhDvJJ1sODSzlhv1y',1,'2026-03-15 00:18:26','admin5'),(4,6,'admin6@admin.local','$2b$10$67QkVPCJO2M0.BCDCtvgWeTUE9XLrY248PxzriAyV44Se.X7DNIzC',1,'2026-04-03 20:58:48','admin6'),(5,7,'admin7@admin.local','$2b$10$67QkVPCJO2M0.BCDCtvgWeTUE9XLrY248PxzriAyV44Se.X7DNIzC',1,'2026-04-03 21:13:56','admin7'),(6,9,'admin9@admin.local','$2b$10$ktdLr9Ccy.B11E14PA1sbevBqI3brqAH0wlsy3bMr6DWwgDoplnQC',1,'2026-04-10 20:16:05','admin9'),(7,11,'admin11@admin.local','$2b$10$wEg7oaYqppJcRWRZXiUXzu5HARqgbpPq9WJFzflIHSZtbK49Uy5wa',1,'2026-04-16 21:40:37','admin11');
/*!40000 ALTER TABLE `office_admins` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `office_users`
--

DROP TABLE IF EXISTS `office_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `office_users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `office_id` int NOT NULL,
  `username` varchar(50) NOT NULL,
  `name` varchar(150) NOT NULL,
  `email` varchar(150) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` varchar(50) NOT NULL DEFAULT 'user',
  `status` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_office_users_email` (`email`),
  UNIQUE KEY `uq_office_users_username` (`username`),
  KEY `idx_office_users_office_id` (`office_id`),
  KEY `idx_office_users_status` (`status`),
  CONSTRAINT `fk_office_users_office` FOREIGN KEY (`office_id`) REFERENCES `offices` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `office_users`
--

LOCK TABLES `office_users` WRITE;
/*!40000 ALTER TABLE `office_users` DISABLE KEYS */;
INSERT INTO `office_users` VALUES (1,1,'mario.usuario','Mario Usuario','mario.usuario@demo.cl','$2b$10$kc9NpHMPzo6hBMaoteBpueghqmhzmCgN/NPHfXvs7PfLp.3UF41Da','user',1,'2026-03-10 16:39:56','2026-03-14 20:07:06'),(2,1,'mario','mario perez','mario@empresa.cl','$2b$10$7agWESdgH0GpaNCwb1vWsOmT7kt5ffP88BD/1H8F2d/5aZPbm4e42','user',1,'2026-03-10 23:49:23','2026-03-22 18:52:56'),(3,4,'mario1','mario1','mario1@solusost.cl','$2b$10$eTZuUbdn5SiXXjU.oj1DtOj9MIteZ43yjf.1jOEGsI922o.uIDg2q','OFFICE_USER',1,'2026-03-26 17:32:27',NULL),(4,7,'mario2','mario2','mario2@gmailcom','$2b$10$3E0ZXf7/KFc7QmSrY/dAmOHQYi10zj5x./Dk/3TlP54.xFx3Pnbam','OFFICE_USER',1,'2026-04-03 21:21:27',NULL),(5,9,'albert','albert','albert9@solusoft.cl','$2b$10$beM0t5ES3XVANshqq6mgtesfW8iVkw.OWLM2rTcOHx2ydifGlB.Hi','OFFICE_USER',1,'2026-04-10 20:41:27','2026-04-10 20:42:19'),(6,7,'mario3','martio3','mario3@gmail.com','$2b$10$mhAs3y.XRUYfRYg6VTPts.Hfvk7APv7SxOpLeLf7VYrjhz1dj91xS','OFFICE_USER',1,'2026-04-20 21:18:47','2026-04-20 21:19:07');
/*!40000 ALTER TABLE `office_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `offices`
--

DROP TABLE IF EXISTS `offices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `offices` (
  `id` int NOT NULL AUTO_INCREMENT,
  `rut` varchar(12) NOT NULL,
  `name` varchar(120) NOT NULL,
  `legal_name` varchar(160) DEFAULT NULL,
  `email` varchar(120) DEFAULT NULL,
  `phone` varchar(30) DEFAULT NULL,
  `status` tinyint NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_offices_rut` (`rut`),
  KEY `idx_offices_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `offices`
--

LOCK TABLES `offices` WRITE;
/*!40000 ALTER TABLE `offices` DISABLE KEYS */;
INSERT INTO `offices` VALUES (1,'76123456-7','Contabilidad Puente Altoactualizar','Servicios Contables Puente Alto SpA','contacto@contapuentealtqo.cl','+56987654321',0,'2026-03-09 00:54:50','2026-04-10 16:18:00'),(4,'76234567-1','Oficina Contable Demo','','demo@oficina.cl','+56998765432',1,'2026-03-14 16:58:40',NULL),(5,'76345678-5','oficina prueba3','prueba7','prueba@prueba.cl','+56974823916',1,'2026-03-14 21:18:26','2026-03-17 15:29:45'),(6,'2-7','oficina prueba 2','oficina prueba 2','oficina@prueba.cl','974823916',1,'2026-04-03 17:58:47',NULL),(7,'3-5','prueba 4','prueba 4','prueba4@gmail.com','45667889',1,'2026-04-03 18:13:56',NULL),(9,'15633802-8','poficina prueba prueba 7','prueba 7 oficial','oficial@pc.cl','66666666',1,'2026-04-10 16:16:05','2026-04-16 17:39:30'),(11,'8095250-3','mario','mario spa','mario@mario.cl','74823916',1,'2026-04-16 17:40:37',NULL);
/*!40000 ALTER TABLE `offices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'contabilidad_master'
--

--
-- Dumping routines for database 'contabilidad_master'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-22 17:10:10
