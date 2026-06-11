CREATE DATABASE  IF NOT EXISTS `contabilidad_master` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `contabilidad_master`;
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
INSERT INTO `account_mappings` VALUES (1,1,'CAJA',1,'','2026-05-21 02:12:21','2026-05-21 02:12:21'),(2,1,'CLIENTES',1,'','2026-05-21 02:12:21','2026-05-21 02:12:21'),(3,1,'PROVEEDORES',11,'','2026-05-21 02:12:21','2026-05-21 02:12:21'),(4,1,'BANCO',1,'','2026-05-21 02:12:21','2026-05-21 02:12:21'),(5,1,'IVA_DEBITO',4,'','2026-05-21 02:12:21','2026-05-21 02:12:21'),(6,1,'IVA_CREDITO',5,'','2026-05-21 02:12:21','2026-05-21 02:12:21'),(7,1,'VENTAS',2,'','2026-05-21 02:12:21','2026-05-21 02:12:21'),(8,1,'COMPRAS',6,'','2026-05-21 02:12:21','2026-05-21 02:12:21'),(9,2,'CAJA',38,'','2026-06-02 00:43:40','2026-06-02 00:43:40'),(10,2,'BANCO',38,'','2026-06-02 00:43:40','2026-06-02 00:43:40'),(11,2,'PROVEEDORES',43,'','2026-06-02 00:43:40','2026-06-02 00:43:40'),(12,2,'CLIENTES',43,'','2026-06-02 00:43:40','2026-06-02 00:43:40'),(13,2,'IVA_CREDITO',42,'','2026-06-02 00:43:40','2026-06-02 00:43:40'),(14,2,'VENTAS',39,'','2026-06-02 00:43:40','2026-06-02 00:43:40'),(15,2,'IVA_DEBITO',41,'','2026-06-02 00:43:40','2026-06-02 00:43:40'),(16,2,'COMPRAS',43,'','2026-06-02 00:43:40','2026-06-02 00:43:40');
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
INSERT INTO `account_plan_base` VALUES (1,'1010101','CAJA','ACTIVO','DEBITO',NULL,1,1,1,10,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-08 18:50:25'),(2,'4010110','VENTAS','INGRESO','CREDITO',NULL,1,1,1,20,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-11 16:23:53'),(3,'4010120','VENTAS EXENTAS','INGRESO','CREDITO',NULL,1,1,1,30,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-11 16:23:53'),(4,'2010925','IVA DEBITO FISCAL','PASIVO','CREDITO',NULL,1,1,1,40,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-11 16:23:53'),(5,'1010802','IVA CREDITO FISCAL','ACTIVO','DEBITO',NULL,1,1,1,50,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-08 18:50:25'),(6,'1010630','MERCADERIA','ACTIVO','DEBITO',NULL,1,1,1,60,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-08 18:50:25'),(7,'1010801','PPM','ACTIVO','DEBITO',NULL,1,1,1,70,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-08 18:50:25'),(8,'30102','CAPITAL','ACTIVO','DEBITO',NULL,1,1,1,80,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-06-02 21:15:06'),(9,'30101','CAPITAL SOCIAL','PATRIMONIO','CREDITO',NULL,1,1,1,90,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-11 16:23:53'),(10,'2010210','CUENTAS POR PAGAR','PASIVO','CREDITO',NULL,1,1,1,100,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-11 16:23:53'),(11,'2010120','VARIOS ACREEDORES','PASIVO','CREDITO',NULL,1,1,1,110,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-11 16:23:53'),(12,'4010601','OTROS INGRESOS','INGRESO','CREDITO',NULL,1,1,1,120,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-11 16:23:53'),(13,'4010890','GASTOS GENERALES','GASTO','DEBITO',NULL,1,1,1,130,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-11 16:23:53'),(14,'4012210','CORRECCION MONETARIA','GASTO','DEBITO',NULL,1,1,1,140,'En hoja aparece como C Monetaria','2026-03-08 18:50:25','2026-03-11 16:23:53'),(15,'30203','PERDIDA Y GANANCIA','RESULTADO','CREDITO',NULL,1,1,1,150,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-11 16:23:53'),(16,'4010701','PERDIDA TRIBUTARIA','GASTO','DEBITO',NULL,1,1,1,160,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-11 16:23:53'),(17,'1010220','RETIROS','ACTIVO','DEBITO',NULL,1,1,1,170,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-08 18:50:25'),(18,'4010220','COSTO DE VENTA','GASTO','DEBITO',NULL,1,1,1,180,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-06-02 18:33:17'),(19,'4010815','ARRIENDOS','GASTO','DEBITO',NULL,1,1,1,190,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-06-02 18:33:17'),(20,'4010810','SUELDOS','GASTO','DEBITO',NULL,1,1,1,200,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-06-02 18:33:17'),(21,'4010822','HONORARIOS','GASTO','DEBITO',NULL,1,1,1,210,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-06-02 18:33:17'),(22,'2010930','RTA 2DA CATG','PASIVO','CREDITO',NULL,1,1,1,220,'Descripcion tal como aparece en hoja','2026-03-08 18:50:25','2026-06-02 18:33:17'),(23,'2010910','IMPUESTO UNICO','PASIVO','CREDITO',NULL,1,1,1,230,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-06-02 18:33:17'),(24,'30202','UTILIDADES POR CAPITALIZAR','PATRIMONIO','CREDITO',NULL,1,1,1,240,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-06-02 18:33:17'),(25,'1020820','MUEBLES Y UTILES','ACTIVO','DEBITO',NULL,1,1,1,250,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-08 18:50:25'),(26,'30601','FDO. REV. CAP. PROPIO','PATRIMONIO','CREDITO',NULL,1,1,1,260,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-06-02 18:33:17'),(27,'2020101','DEPRE. ACUMULADA','PASIVO','CREDITO',NULL,1,1,1,270,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-06-02 18:33:17'),(28,'1010353','VEHICULO','ACTIVO','DEBITO',NULL,1,1,1,280,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-08 18:50:25'),(29,'2020601','FDO UTILID. ACUMULADAS','PATRIMONIO','CREDITO',NULL,1,1,1,290,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-06-02 18:33:17'),(30,'1010310','HERRAMIENTAS','ACTIVO','DEBITO',NULL,1,1,1,300,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-08 18:50:25'),(31,'1020810','MAQUINARIAS','ACTIVO','DEBITO',NULL,1,1,1,310,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-08 18:50:25'),(32,'1010370','PRESTAMO SOLIDARIO','ACTIVO','DEBITO',NULL,1,1,1,320,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-08 18:50:25'),(33,'4012570','IMPTO. RTA. PRIMERA CATG.','GASTO','DEBITO',NULL,1,1,1,330,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-06-02 18:33:17'),(34,'30103','CTA. CAP. SOCIO 1','ACTIVO','DEBITO',NULL,1,1,1,340,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-08 18:50:25'),(35,'30104','CTA. CAP. SOCIO 2','ACTIVO','DEBITO',NULL,1,1,1,350,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-08 18:50:25'),(36,'1020201','GARANTIA ARRIENDO','ACTIVO','DEBITO',NULL,1,1,1,360,'Extraido de imagen enviada por usuario','2026-03-08 18:50:25','2026-03-08 18:50:25'),(37,'4010916','COMPRA EXENTAS','GASTO','DEBITO',NULL,1,1,1,370,'Descripcion tal como aparece en hoja','2026-03-08 18:50:25','2026-06-02 18:33:17');
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
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounting_periods`
--

LOCK TABLES `accounting_periods` WRITE;
/*!40000 ALTER TABLE `accounting_periods` DISABLE KEYS */;
INSERT INTO `accounting_periods` VALUES (1,1,2026,'2026-01-01','2026-12-31','OPEN',1,'Periodo inicial creado automaticamente para la empresa mario empresa','2026-05-21 02:08:23','2026-05-21 02:12:21'),(2,1,2025,'2025-01-01','2025-12-31','CLOSED',1,'Período creado manualmente','2026-05-31 18:48:30','2026-06-01 02:55:41'),(3,2,2025,'2025-01-01','2025-12-31','OPEN',1,'Periodo inicial creado automaticamente para la empresa MIGUEL VERA BAUCLIN','2026-06-02 00:40:57','2026-06-02 00:43:39');
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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `companies`
--

LOCK TABLES `companies` WRITE;
/*!40000 ALTER TABLE `companies` DISABLE KEYS */;
INSERT INTO `companies` VALUES (1,2,'mario empresa','empresa prueba','prueba',NULL,'15.633.802-8','prueba dir','puente alto','santiago','metropolitana','9944','empresa@mario.cl','active','veamos','2026-05-21 02:08:23','2026-05-21 02:08:45'),(2,1,'MIGUEL VERA BAUCLIN','MIGUEL VERA BAUCLIN','CONSTRUCCION',NULL,'10.583.923-5','CHUPALLA 21 MIRAFLORES ALTO CURACAVI','CURACAVI','SANTIAGO','METROPOLITANA','972113819','contadora.carmen.cabezas@gmail.com','active',NULL,'2026-06-02 00:40:57','2026-06-02 00:40:57');
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
  KEY `idx_company_accounts_active` (`is_active`),
  KEY `idx_ca_company` (`company_id`)
) ENGINE=InnoDB AUTO_INCREMENT=75 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `company_accounts`
--

LOCK TABLES `company_accounts` WRITE;
/*!40000 ALTER TABLE `company_accounts` DISABLE KEYS */;
INSERT INTO `company_accounts` VALUES (1,1,'1010101','CAJA','ACTIVO','DEBITO',NULL,1,1,1,10,'Extraido de imagen enviada por usuario','2026-05-21 02:08:23','2026-05-21 02:08:23'),(2,1,'4010110','VENTAS','INGRESO','CREDITO',NULL,1,1,1,20,'Extraido de imagen enviada por usuario','2026-05-21 02:08:23','2026-05-21 02:08:23'),(3,1,'4010120','VENTAS EXENTAS','INGRESO','CREDITO',NULL,1,1,1,30,'Extraido de imagen enviada por usuario','2026-05-21 02:08:23','2026-05-21 02:08:23'),(4,1,'2010925','IVA DEBITO FISCAL','PASIVO','CREDITO',NULL,1,1,1,40,'Extraido de imagen enviada por usuario','2026-05-21 02:08:23','2026-05-21 02:08:23'),(5,1,'1010802','IVA CREDITO FISCAL','ACTIVO','DEBITO',NULL,1,1,1,50,'Extraido de imagen enviada por usuario','2026-05-21 02:08:23','2026-05-21 02:08:23'),(6,1,'1010630','MERCADERIA','ACTIVO','DEBITO',NULL,1,1,1,60,'Extraido de imagen enviada por usuario','2026-05-21 02:08:23','2026-05-21 02:08:23'),(7,1,'1010801','PPM','ACTIVO','DEBITO',NULL,1,1,1,70,'Extraido de imagen enviada por usuario','2026-05-21 02:08:23','2026-05-21 02:08:23'),(8,1,'30102','CAPITAL','ACTIVO','DEBITO',NULL,1,1,1,80,'Extraido de imagen enviada por usuario','2026-05-21 02:08:23','2026-06-02 21:16:25'),(9,1,'30101','CAPITAL SOCIAL','PATRIMONIO','CREDITO',NULL,1,1,1,90,'Extraido de imagen enviada por usuario','2026-05-21 02:08:23','2026-05-21 02:08:23'),(10,1,'2010210','CUENTAS POR PAGAR','PASIVO','CREDITO',NULL,1,1,1,100,'Extraido de imagen enviada por usuario','2026-05-21 02:08:23','2026-05-21 02:08:23'),(11,1,'2010120','VARIOS ACREEDORES','PASIVO','CREDITO',NULL,1,1,1,110,'Extraido de imagen enviada por usuario','2026-05-21 02:08:23','2026-05-21 02:08:23'),(12,1,'4010601','OTROS INGRESOS','INGRESO','CREDITO',NULL,1,1,1,120,'Extraido de imagen enviada por usuario','2026-05-21 02:08:23','2026-05-21 02:08:23'),(13,1,'4010890','GASTOS GENERALES','GASTO','DEBITO',NULL,1,1,1,130,'Extraido de imagen enviada por usuario','2026-05-21 02:08:23','2026-05-21 02:08:23'),(14,1,'4012210','CORRECCION MONETARIA','GASTO','DEBITO',NULL,1,1,1,140,'En hoja aparece como C Monetaria','2026-05-21 02:08:23','2026-05-21 02:08:23'),(15,1,'30203','PERDIDA Y GANANCIA','RESULTADO','CREDITO',NULL,1,1,1,150,'Extraido de imagen enviada por usuario','2026-05-21 02:08:23','2026-05-21 02:08:23'),(16,1,'4010701','PERDIDA TRIBUTARIA','GASTO','DEBITO',NULL,1,1,1,160,'Extraido de imagen enviada por usuario','2026-05-21 02:08:23','2026-05-21 02:08:23'),(17,1,'1010220','RETIROS','ACTIVO','DEBITO',NULL,1,1,1,170,'Extraido de imagen enviada por usuario','2026-05-21 02:08:23','2026-05-21 02:08:23'),(18,1,'4010220','COSTO DE VENTA','GASTO','DEBITO',NULL,1,1,1,180,'Extraido de imagen enviada por usuario','2026-05-21 02:08:23','2026-06-02 18:35:17'),(19,1,'4010815','ARRIENDOS','GASTO','DEBITO',NULL,1,1,1,190,'Extraido de imagen enviada por usuario','2026-05-21 02:08:23','2026-06-02 18:35:17'),(20,1,'4010810','SUELDOS','GASTO','DEBITO',NULL,1,1,1,200,'Extraido de imagen enviada por usuario','2026-05-21 02:08:23','2026-06-02 18:35:17'),(21,1,'4010822','HONORARIOS','GASTO','DEBITO',NULL,1,1,1,210,'Extraido de imagen enviada por usuario','2026-05-21 02:08:23','2026-06-02 18:35:17'),(22,1,'2010930','RTA 2DA CATG','PASIVO','CREDITO',NULL,1,1,1,220,'Descripcion tal como aparece en hoja','2026-05-21 02:08:23','2026-06-02 18:35:17'),(23,1,'2010910','IMPUESTO UNICO','PASIVO','CREDITO',NULL,1,1,1,230,'Extraido de imagen enviada por usuario','2026-05-21 02:08:23','2026-06-02 18:35:17'),(24,1,'30202','UTILIDADES POR CAPITALIZAR','PATRIMONIO','CREDITO',NULL,1,1,1,240,'Extraido de imagen enviada por usuario','2026-05-21 02:08:23','2026-06-02 18:35:17'),(25,1,'1020820','MUEBLES Y UTILES','ACTIVO','DEBITO',NULL,1,1,1,250,'Extraido de imagen enviada por usuario','2026-05-21 02:08:23','2026-05-21 02:08:23'),(26,1,'30601','FDO. REV. CAP. PROPIO','PATRIMONIO','CREDITO',NULL,1,1,1,260,'Extraido de imagen enviada por usuario','2026-05-21 02:08:23','2026-06-02 18:35:17'),(27,1,'2020101','DEPRE. ACUMULADA','PASIVO','CREDITO',NULL,1,1,1,270,'Extraido de imagen enviada por usuario','2026-05-21 02:08:23','2026-06-02 18:35:17'),(28,1,'1010353','VEHICULO','ACTIVO','DEBITO',NULL,1,1,1,280,'Extraido de imagen enviada por usuario','2026-05-21 02:08:23','2026-05-21 02:08:23'),(29,1,'2020601','FDO UTILID. ACUMULADAS','PATRIMONIO','CREDITO',NULL,1,1,1,290,'Extraido de imagen enviada por usuario','2026-05-21 02:08:23','2026-06-02 18:35:17'),(30,1,'1010310','HERRAMIENTAS','ACTIVO','DEBITO',NULL,1,1,1,300,'Extraido de imagen enviada por usuario','2026-05-21 02:08:23','2026-05-21 02:08:23'),(31,1,'1020810','MAQUINARIAS','ACTIVO','DEBITO',NULL,1,1,1,310,'Extraido de imagen enviada por usuario','2026-05-21 02:08:23','2026-05-21 02:08:23'),(32,1,'1010370','PRESTAMO SOLIDARIO','ACTIVO','DEBITO',NULL,1,1,1,320,'Extraido de imagen enviada por usuario','2026-05-21 02:08:23','2026-05-21 02:08:23'),(33,1,'4012570','IMPTO. RTA. PRIMERA CATG.','GASTO','DEBITO',NULL,1,1,1,330,'Extraido de imagen enviada por usuario','2026-05-21 02:08:23','2026-06-02 18:35:17'),(34,1,'30103','CTA. CAP. SOCIO 1','ACTIVO','DEBITO',NULL,1,1,1,340,'Extraido de imagen enviada por usuario','2026-05-21 02:08:23','2026-05-21 02:08:23'),(35,1,'30104','CTA. CAP. SOCIO 2','ACTIVO','DEBITO',NULL,1,1,1,350,'Extraido de imagen enviada por usuario','2026-05-21 02:08:23','2026-05-21 02:08:23'),(36,1,'1020201','GARANTIA ARRIENDO','ACTIVO','DEBITO',NULL,1,1,1,360,'Extraido de imagen enviada por usuario','2026-05-21 02:08:23','2026-05-21 02:08:23'),(37,1,'4010916','COMPRA EXENTAS','GASTO','DEBITO',NULL,1,1,1,370,'Descripcion tal como aparece en hoja','2026-05-21 02:08:23','2026-06-02 18:35:17'),(38,2,'1010101','CAJA','ACTIVO','DEBITO',NULL,1,1,1,10,'Extraido de imagen enviada por usuario','2026-06-02 00:40:57','2026-06-02 00:40:57'),(39,2,'4010110','VENTAS','INGRESO','CREDITO',NULL,1,1,1,20,'Extraido de imagen enviada por usuario','2026-06-02 00:40:57','2026-06-02 00:40:57'),(40,2,'4010120','VENTAS EXENTAS','INGRESO','CREDITO',NULL,1,1,1,30,'Extraido de imagen enviada por usuario','2026-06-02 00:40:57','2026-06-02 00:40:57'),(41,2,'2010925','IVA DEBITO FISCAL','PASIVO','CREDITO',NULL,1,1,1,40,'Extraido de imagen enviada por usuario','2026-06-02 00:40:57','2026-06-02 00:40:57'),(42,2,'1010802','IVA CREDITO FISCAL','ACTIVO','DEBITO',NULL,1,1,1,50,'Extraido de imagen enviada por usuario','2026-06-02 00:40:57','2026-06-02 00:40:57'),(43,2,'1010630','MERCADERIA','ACTIVO','DEBITO',NULL,1,1,1,60,'Extraido de imagen enviada por usuario','2026-06-02 00:40:57','2026-06-02 00:40:57'),(44,2,'1010801','PPM','ACTIVO','DEBITO',NULL,1,1,1,70,'Extraido de imagen enviada por usuario','2026-06-02 00:40:57','2026-06-02 00:40:57'),(45,2,'30102','CAPITAL','ACTIVO','DEBITO',NULL,1,1,1,80,'Extraido de imagen enviada por usuario','2026-06-02 00:40:57','2026-06-02 21:16:25'),(46,2,'30101','CAPITAL SOCIAL','PATRIMONIO','CREDITO',NULL,1,1,1,90,'Extraido de imagen enviada por usuario','2026-06-02 00:40:57','2026-06-02 00:40:57'),(47,2,'2010210','CUENTAS POR PAGAR','PASIVO','CREDITO',NULL,1,1,1,100,'Extraido de imagen enviada por usuario','2026-06-02 00:40:57','2026-06-02 00:40:57'),(48,2,'2010120','VARIOS ACREEDORES','PASIVO','CREDITO',NULL,1,1,1,110,'Extraido de imagen enviada por usuario','2026-06-02 00:40:57','2026-06-02 00:40:57'),(49,2,'4010601','OTROS INGRESOS','INGRESO','CREDITO',NULL,1,1,1,120,'Extraido de imagen enviada por usuario','2026-06-02 00:40:57','2026-06-02 00:40:57'),(50,2,'4010890','GASTOS GENERALES','GASTO','DEBITO',NULL,1,1,1,130,'Extraido de imagen enviada por usuario','2026-06-02 00:40:57','2026-06-02 00:40:57'),(51,2,'4012210','CORRECCION MONETARIA','GASTO','DEBITO',NULL,1,1,1,140,'En hoja aparece como C Monetaria','2026-06-02 00:40:57','2026-06-02 00:40:57'),(52,2,'30203','PERDIDA Y GANANCIA','RESULTADO','CREDITO',NULL,1,1,1,150,'Extraido de imagen enviada por usuario','2026-06-02 00:40:57','2026-06-02 00:40:57'),(53,2,'4010701','PERDIDA TRIBUTARIA','GASTO','DEBITO',NULL,1,1,1,160,'Extraido de imagen enviada por usuario','2026-06-02 00:40:57','2026-06-02 00:40:57'),(54,2,'1010220','RETIROS','ACTIVO','DEBITO',NULL,1,1,1,170,'Extraido de imagen enviada por usuario','2026-06-02 00:40:57','2026-06-02 00:40:57'),(55,2,'4010220','COSTO DE VENTA','GASTO','DEBITO',NULL,1,1,1,180,'Extraido de imagen enviada por usuario','2026-06-02 00:40:57','2026-06-02 18:35:17'),(56,2,'4010815','ARRIENDOS','GASTO','DEBITO',NULL,1,1,1,190,'Extraido de imagen enviada por usuario','2026-06-02 00:40:57','2026-06-02 18:35:17'),(57,2,'4010810','SUELDOS','GASTO','DEBITO',NULL,1,1,1,200,'Extraido de imagen enviada por usuario','2026-06-02 00:40:57','2026-06-02 18:35:17'),(58,2,'4010822','HONORARIOS','GASTO','DEBITO',NULL,1,1,1,210,'Extraido de imagen enviada por usuario','2026-06-02 00:40:57','2026-06-02 18:35:17'),(59,2,'2010930','RTA 2DA CATG','PASIVO','CREDITO',NULL,1,1,1,220,'Descripcion tal como aparece en hoja','2026-06-02 00:40:57','2026-06-02 18:35:17'),(60,2,'2010910','IMPUESTO UNICO','PASIVO','CREDITO',NULL,1,1,1,230,'Extraido de imagen enviada por usuario','2026-06-02 00:40:57','2026-06-02 18:35:17'),(61,2,'30202','UTILIDADES POR CAPITALIZAR','PATRIMONIO','CREDITO',NULL,1,1,1,240,'Extraido de imagen enviada por usuario','2026-06-02 00:40:57','2026-06-02 18:35:17'),(62,2,'1020820','MUEBLES Y UTILES','ACTIVO','DEBITO',NULL,1,1,1,250,'Extraido de imagen enviada por usuario','2026-06-02 00:40:57','2026-06-02 00:40:57'),(63,2,'30601','FDO. REV. CAP. PROPIO','PATRIMONIO','CREDITO',NULL,1,1,1,260,'Extraido de imagen enviada por usuario','2026-06-02 00:40:57','2026-06-02 18:35:17'),(64,2,'2020101','DEPRE. ACUMULADA','PASIVO','CREDITO',NULL,1,1,1,270,'Extraido de imagen enviada por usuario','2026-06-02 00:40:57','2026-06-02 18:35:17'),(65,2,'1010353','VEHICULO','ACTIVO','DEBITO',NULL,1,1,1,280,'Extraido de imagen enviada por usuario','2026-06-02 00:40:57','2026-06-02 00:40:57'),(66,2,'2020601','FDO UTILID. ACUMULADAS','PATRIMONIO','CREDITO',NULL,1,1,1,290,'Extraido de imagen enviada por usuario','2026-06-02 00:40:57','2026-06-02 18:35:17'),(67,2,'1010310','HERRAMIENTAS','ACTIVO','DEBITO',NULL,1,1,1,300,'Extraido de imagen enviada por usuario','2026-06-02 00:40:57','2026-06-02 00:40:57'),(68,2,'1020810','MAQUINARIAS','ACTIVO','DEBITO',NULL,1,1,1,310,'Extraido de imagen enviada por usuario','2026-06-02 00:40:57','2026-06-02 00:40:57'),(69,2,'1010370','PRESTAMO SOLIDARIO','ACTIVO','DEBITO',NULL,1,1,1,320,'Extraido de imagen enviada por usuario','2026-06-02 00:40:57','2026-06-02 00:40:57'),(70,2,'4012570','IMPTO. RTA. PRIMERA CATG.','GASTO','DEBITO',NULL,1,1,1,330,'Extraido de imagen enviada por usuario','2026-06-02 00:40:57','2026-06-02 18:35:17'),(71,2,'30103','CTA. CAP. SOCIO 1','ACTIVO','DEBITO',NULL,1,1,1,340,'Extraido de imagen enviada por usuario','2026-06-02 00:40:57','2026-06-02 00:40:57'),(72,2,'30104','CTA. CAP. SOCIO 2','ACTIVO','DEBITO',NULL,1,1,1,350,'Extraido de imagen enviada por usuario','2026-06-02 00:40:57','2026-06-02 00:40:57'),(73,2,'1020201','GARANTIA ARRIENDO','ACTIVO','DEBITO',NULL,1,1,1,360,'Extraido de imagen enviada por usuario','2026-06-02 00:40:57','2026-06-02 00:40:57'),(74,2,'4010916','COMPRA EXENTAS','GASTO','DEBITO',NULL,1,1,1,370,'Descripcion tal como aparece en hoja','2026-06-02 00:40:57','2026-06-02 18:35:17');
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
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `journal_entries`
--

LOCK TABLES `journal_entries` WRITE;
/*!40000 ALTER TABLE `journal_entries` DISABLE KEYS */;
INSERT INTO `journal_entries` VALUES (1,1,'2026-05-21','APERTURA','prueba de asiento','1',NULL,'2026-05-21 02:20:13','2026-05-21 02:20:13'),(2,2,'2025-01-01','APERTURA','REAPERTURA','1',NULL,'2026-06-02 00:53:16','2026-06-02 00:53:16'),(3,2,'2025-01-31','MANUAL','COMPRAS DEL MES','1',NULL,'2026-06-02 01:05:24','2026-06-02 01:05:24'),(4,2,'2025-02-28','MANUAL','INGRESOS DEL MES','1',NULL,'2026-06-02 01:09:19','2026-06-02 01:09:19'),(5,2,'2025-02-28','AJUSTE','COMPRAS DEL MES','1',NULL,'2026-06-02 01:14:12','2026-06-02 01:14:12'),(6,2,'2025-03-31','MANUAL','PAGOS IMPUESTOS FEBRERO','1',NULL,'2026-06-02 01:16:04','2026-06-02 01:16:04'),(7,2,'2025-03-31','MANUAL','INGRESOS DEL MES','1',NULL,'2026-06-02 01:18:07','2026-06-02 01:18:07'),(8,2,'2025-03-31','MANUAL','COMPRAS DEL MES','1',NULL,'2026-06-02 01:20:17','2026-06-02 01:20:17'),(9,2,'2025-04-30','MANUAL','PAGOS IMPUESTOS MARZO','1',NULL,'2026-06-02 01:22:01','2026-06-02 01:22:01'),(10,2,'2025-04-30','MANUAL','COMPRAS DEL MES','1',NULL,'2026-06-02 01:24:26','2026-06-02 01:24:26'),(11,2,'2025-05-30','MANUAL','INGRESOS DEL MES','1',NULL,'2026-06-02 01:27:40','2026-06-02 01:27:40'),(12,2,'2025-05-31','MANUAL','COMPRAS DEL MES','1',NULL,'2026-06-02 01:30:41','2026-06-02 01:30:41'),(13,2,'2025-06-30','MANUAL','PATGOS IMPUESTOS MAYO','1',NULL,'2026-06-02 01:32:16','2026-06-02 01:32:16'),(14,2,'2025-06-30','MANUAL','INGRSDOS DEL MES','1',NULL,'2026-06-02 01:34:12','2026-06-02 01:34:12'),(15,2,'2025-06-30','MANUAL','COMPRAS DEL MES','1',NULL,'2026-06-02 01:36:14','2026-06-02 01:36:14'),(16,2,'2025-07-30','MANUAL','PAGOS IMPUESTYODS JUNIO','1',NULL,'2026-06-02 01:39:58','2026-06-02 01:39:58'),(17,2,'2025-07-31','MANUAL','INGRESOS DEL MES','1',NULL,'2026-06-02 01:41:51','2026-06-02 01:41:51'),(18,2,'2025-07-31','MANUAL','COMPRAS DEL MES','1',NULL,'2026-06-02 01:44:08','2026-06-02 01:44:08'),(19,2,'2025-08-31','MANUAL','PAGOS IMPUESTOS JULIO','1',NULL,'2026-06-02 01:47:07','2026-06-02 01:47:07'),(20,2,'2025-08-31','MANUAL','INGRESOS DEL MES','1',NULL,'2026-06-02 01:49:07','2026-06-02 01:49:07'),(21,2,'2025-08-31','MANUAL','COMPRAS DEL MES','1',NULL,'2026-06-02 01:50:40','2026-06-02 01:50:40'),(22,2,'2025-09-30','MANUAL','PAGOS IMPUESTOS AGOSTO','1',NULL,'2026-06-02 01:52:49','2026-06-02 01:52:49'),(23,2,'2025-09-30','MANUAL','INGRESOS DEL MES','1',NULL,'2026-06-02 01:54:58','2026-06-02 01:54:58'),(24,2,'2025-09-30','MANUAL','COMPRAS DEL MES','1',NULL,'2026-06-02 01:56:24','2026-06-02 01:56:24'),(25,2,'2025-10-30','MANUAL','PAGHOS  IMPUESTYOS SEPTYIEMBRE','1',NULL,'2026-06-02 01:58:23','2026-06-02 01:58:23'),(26,2,'2025-10-31','MANUAL','COMPRAS DEL MES','1',NULL,'2026-06-02 01:59:48','2026-06-02 01:59:48'),(27,2,'2025-11-30','MANUAL','COMPRAS DEL MES','1',NULL,'2026-06-02 02:03:36','2026-06-02 02:03:36'),(28,2,'2025-12-31','MANUAL','COMPRAS','1',NULL,'2026-06-02 02:05:19','2026-06-02 02:05:19'),(29,2,'2025-12-31','MANUAL','RETIROS','1',NULL,'2026-06-02 02:06:35','2026-06-02 02:06:35'),(30,2,'2025-12-31','AJUSTE','AJUSTE CRRDITO FISCL','1',NULL,'2026-06-02 02:07:43','2026-06-02 02:07:43'),(31,2,'2025-12-31','AJUSTE','SE CORRIGE PPM','1',NULL,'2026-06-02 02:08:58','2026-06-02 02:08:58'),(32,2,'2025-12-31','AJUSTE','AJUSTE PERDIDA','1',NULL,'2026-06-02 02:10:33','2026-06-02 02:10:33'),(33,2,'2025-12-31','AJUSTE','COSTO DE VENTA','1',NULL,'2026-06-02 02:12:27','2026-06-02 02:12:27'),(34,2,'2025-01-31','MANUAL','PAGOS CUENTAS POR PAGAR','1',NULL,'2026-06-02 02:21:10','2026-06-02 02:21:10'),(35,2,'2025-01-31','AJUSTE','PAGO CUENTAS POR PAGAR','1',NULL,'2026-06-02 02:23:26','2026-06-02 02:23:26'),(36,2,'2025-12-31','MANUAL','CUENTAS POR PAGAR','1',NULL,'2026-06-02 02:25:08','2026-06-02 02:25:08'),(37,2,'2025-05-31','MANUAL','DEVOLUCION PPM','1',NULL,'2026-06-02 02:32:59','2026-06-02 02:32:59'),(38,2,'2025-05-31','AJUSTE','DSEVOLUCION PPM','1',NULL,'2026-06-02 02:34:33','2026-06-02 02:34:33');
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
  KEY `idx_jel_entry_account` (`entry_id`,`account_id`),
  CONSTRAINT `fk_journal_entry_lines_account` FOREIGN KEY (`account_id`) REFERENCES `company_accounts` (`id`),
  CONSTRAINT `fk_journal_entry_lines_entry` FOREIGN KEY (`entry_id`) REFERENCES `journal_entries` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=146 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `journal_entry_lines`
--

LOCK TABLES `journal_entry_lines` WRITE;
/*!40000 ALTER TABLE `journal_entry_lines` DISABLE KEYS */;
INSERT INTO `journal_entry_lines` VALUES (1,1,2,'',10000.00,0.00),(2,1,6,'',0.00,10000.00),(31,2,38,'CAJA',4048551.00,0.00),(32,2,54,'',8285443.00,0.00),(33,2,67,'',119488.00,0.00),(34,2,44,'',109156.00,0.00),(35,2,42,'',15926694.00,0.00),(36,2,68,'',1422115.00,0.00),(37,2,62,'',707137.00,0.00),(38,2,52,'',548219.00,0.00),(39,2,47,'',0.00,196615.00),(40,2,41,'',0.00,15926694.00),(41,2,64,'',0.00,2248740.00),(42,2,45,'',0.00,12129726.00),(43,2,63,'',0.00,665028.00),(44,2,53,'',548219.00,0.00),(45,2,52,'',0.00,548219.00),(46,3,43,'',1872686.00,0.00),(47,3,42,'',336067.00,0.00),(48,3,38,'',0.00,2208753.00),(49,4,38,'',1995668.00,0.00),(50,4,39,'',0.00,1677032.00),(51,4,41,'',0.00,318636.00),(52,5,43,'',2205144.00,0.00),(53,5,42,'',342314.00,0.00),(54,5,38,'',0.00,2547458.00),(55,6,44,'',16760.00,0.00),(56,6,38,'',0.00,16760.00),(57,7,38,'',8021896.00,0.00),(58,7,39,'',0.00,6741089.00),(59,7,41,'',0.00,1280807.00),(60,8,43,'',3618368.00,0.00),(61,8,42,'',630708.00,0.00),(62,8,38,'',0.00,4249076.00),(63,9,42,'',285345.00,0.00),(64,9,44,'',67411.00,0.00),(65,9,38,'',0.00,352756.00),(66,10,43,'',244590.00,0.00),(67,10,42,'',5316.00,0.00),(68,10,38,'',0.00,249906.00),(69,11,38,'',1882743.00,0.00),(70,11,39,'',0.00,1582137.00),(71,11,41,'',0.00,300606.00),(72,12,43,'',932258.00,0.00),(73,12,42,'',61561.00,0.00),(74,12,38,'',0.00,993819.00),(75,13,42,'',229268.00,0.00),(76,13,44,'',15821.00,0.00),(77,13,38,'',0.00,245089.00),(78,14,38,'',1828817.00,0.00),(79,14,39,'',0.00,1536821.00),(80,14,41,'',0.00,291996.00),(81,15,43,'',427535.00,0.00),(82,15,42,'',7265.00,0.00),(83,15,38,'',0.00,434800.00),(84,16,42,'',284731.00,0.00),(85,16,44,'',15368.00,0.00),(86,16,38,'',0.00,300099.00),(87,17,38,'',766466.00,0.00),(88,17,39,'',0.00,644089.00),(89,17,41,'',0.00,122377.00),(93,18,43,'',910717.00,0.00),(94,18,42,'',25889.00,0.00),(95,18,38,'',0.00,936606.00),(96,19,42,'',96488.00,0.00),(97,19,44,'',6441.00,0.00),(98,19,38,'',0.00,102929.00),(99,20,38,'',849629.00,0.00),(100,20,39,'',0.00,713974.00),(101,20,41,'',0.00,135655.00),(102,21,43,'',1090067.00,0.00),(103,21,42,'',90415.00,0.00),(104,21,38,'',0.00,1180482.00),(105,22,42,'',45240.00,0.00),(106,22,44,'',7140.00,0.00),(107,22,38,'',0.00,52380.00),(108,23,38,'',672550.00,0.00),(109,23,39,'',0.00,565168.00),(110,23,41,'',0.00,107382.00),(111,24,43,'',119014.00,0.00),(112,24,42,'',19247.00,0.00),(113,24,38,'',0.00,138261.00),(114,25,42,'',88135.00,0.00),(115,25,44,'',5652.00,0.00),(116,25,38,'',0.00,93787.00),(117,26,43,'',270787.00,0.00),(118,26,42,'',21780.00,0.00),(119,26,38,'',0.00,292567.00),(120,27,43,'',642954.00,0.00),(121,27,42,'',113691.00,0.00),(122,27,38,'',0.00,756645.00),(123,28,43,'',50033.00,0.00),(124,28,42,'',4986.00,0.00),(125,28,38,'',0.00,55019.00),(126,29,54,'',1200000.00,0.00),(127,29,38,'',0.00,1200000.00),(128,30,42,'',93166.00,0.00),(129,30,38,'',0.00,93166.00),(130,31,44,'',2018.00,0.00),(131,31,51,'',0.00,2018.00),(132,32,53,'',16730.00,0.00),(133,32,38,'',0.00,16730.00),(134,33,55,'',12415182.00,0.00),(135,33,43,'',0.00,12415182.00),(136,34,47,'',196615.00,0.00),(137,34,38,'',0.00,196615.00),(138,35,47,'',196615.00,0.00),(139,35,38,'',0.00,196615.00),(140,36,47,'',196615.00,0.00),(141,36,38,'',0.00,196615.00),(142,37,38,'',109156.00,0.00),(143,37,44,'',0.00,109156.00),(144,38,38,'',109156.00,0.00),(145,38,44,'',0.00,109156.00);
/*!40000 ALTER TABLE `journal_entry_lines` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `libro_cv`
--

DROP TABLE IF EXISTS `libro_cv`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `libro_cv` (
  `id` int NOT NULL AUTO_INCREMENT,
  `company_id` int NOT NULL,
  `periodo` varchar(7) NOT NULL,
  `tipo_libro` enum('COMPRA','VENTA') NOT NULL,
  `archivo_nombre` varchar(255) DEFAULT NULL,
  `fecha_importacion` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_company_periodo` (`company_id`,`periodo`),
  CONSTRAINT `fk_libro_cv_company` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `libro_cv`
--

LOCK TABLES `libro_cv` WRITE;
/*!40000 ALTER TABLE `libro_cv` DISABLE KEYS */;
/*!40000 ALTER TABLE `libro_cv` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `libro_cv_detalle`
--

DROP TABLE IF EXISTS `libro_cv_detalle`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `libro_cv_detalle` (
  `id` int NOT NULL AUTO_INCREMENT,
  `libro_cv_id` int NOT NULL,
  `tipo_documento` varchar(100) DEFAULT NULL,
  `total_documentos` int DEFAULT '0',
  `monto_exento` decimal(15,2) DEFAULT '0.00',
  `monto_neto` decimal(15,2) DEFAULT '0.00',
  `iva_recuperable` decimal(15,2) DEFAULT '0.00',
  `iva_uso_comun` decimal(15,2) DEFAULT '0.00',
  `iva_no_recuperable` decimal(15,2) DEFAULT '0.00',
  `monto_iva` decimal(15,2) DEFAULT '0.00',
  `monto_total` decimal(15,2) DEFAULT '0.00',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_libro_cv` (`libro_cv_id`),
  CONSTRAINT `fk_libro_cv_detalle` FOREIGN KEY (`libro_cv_id`) REFERENCES `libro_cv` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `libro_cv_detalle`
--

LOCK TABLES `libro_cv_detalle` WRITE;
/*!40000 ALTER TABLE `libro_cv_detalle` DISABLE KEYS */;
/*!40000 ALTER TABLE `libro_cv_detalle` ENABLE KEYS */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `office_admins`
--

LOCK TABLES `office_admins` WRITE;
/*!40000 ALTER TABLE `office_admins` DISABLE KEYS */;
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
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `unique_office_username` (`office_id`,`username`),
  UNIQUE KEY `unique_office_email` (`office_id`,`email`),
  KEY `idx_office_users_office_id` (`office_id`),
  KEY `idx_office_users_status` (`status`),
  CONSTRAINT `fk_office_users_office` FOREIGN KEY (`office_id`) REFERENCES `offices` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `office_users`
--

LOCK TABLES `office_users` WRITE;
/*!40000 ALTER TABLE `office_users` DISABLE KEYS */;
INSERT INTO `office_users` VALUES (1,1,'carmen','administrador carmen','contadora.carmen.cabezas@gmail.com','$2b$10$D0HNoYX.RnvD0Z8l81U7R.0bCmfLj5P9QGr48kabRS6cwdIZy.oPy','OFFICE_ADMIN',1,'2026-05-20 19:30:12',NULL),(2,2,'admin','admin prueba','pruebaadmin@solusoft.cl','$2b$10$y5mnsyva0naOeI5SwGz3nOlC4i0NAipHX.qUOz14TV1pQZ4PlLOTW','OFFICE_ADMIN',1,'2026-05-21 01:37:18',NULL),(5,2,'usuario','prueba1usuaio','usuario@usuario.cl','$2b$10$w8phPTXkq.qnN2E3mmWzzezVF2KC3OO4nvqGPmGhaWPQWNJZaGxLW','OFFICE_USER',1,'2026-06-11 02:17:58',NULL);
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
  `plan_id` int DEFAULT NULL,
  `subscription_status` varchar(20) NOT NULL DEFAULT 'BETA',
  `subscription_start` date DEFAULT NULL,
  `subscription_end` date DEFAULT NULL,
  `is_suspended` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_offices_rut` (`rut`),
  KEY `idx_offices_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `offices`
--

LOCK TABLES `offices` WRITE;
/*!40000 ALTER TABLE `offices` DISABLE KEYS */;
INSERT INTO `offices` VALUES (1,'77.094.826-6','Oficina Carmen','Oficina Carmen','contadora.carmen.cabezas@gmail.com','962068065',1,'2026-05-20 15:30:11','2026-06-10 13:45:37',3,'ACTIVE','2026-06-08','2099-12-31',0),(2,'1-9','oficina prueba','prueba','prueba@solusoft.cl','888',1,'2026-05-20 21:37:18','2026-06-10 13:51:19',1,'ACTIVE','2026-06-08','2026-07-08',0);
/*!40000 ALTER TABLE `offices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `plans`
--

DROP TABLE IF EXISTS `plans`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `plans` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `max_companies` int NOT NULL DEFAULT '1',
  `max_users` int NOT NULL DEFAULT '1',
  `monthly_price` decimal(12,2) NOT NULL DEFAULT '0.00',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `plans`
--

LOCK TABLES `plans` WRITE;
/*!40000 ALTER TABLE `plans` DISABLE KEYS */;
INSERT INTO `plans` VALUES (1,'Beta',1,2,0.00,1,'2026-06-08 16:25:56'),(2,'Básico',5,5,19990.00,1,'2026-06-08 16:25:56'),(3,'Profesional',20,20,49990.00,1,'2026-06-08 16:25:56');
/*!40000 ALTER TABLE `plans` ENABLE KEYS */;
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

-- Dump completed on 2026-06-11 13:03:07
