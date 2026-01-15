-- MariaDB dump 10.19.7-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: db_psb
-- ------------------------------------------------------
-- Server version	10.11.4-MariaDB-1~deb12u1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `anggota_rombels`
--

DROP TABLE IF EXISTS `anggota_rombels`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `anggota_rombels` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `rombongan_belajar_id` bigint(20) unsigned NOT NULL,
  `siswa_id` bigint(20) unsigned NOT NULL,
  `nomor_absen` smallint(5) unsigned DEFAULT NULL COMMENT 'Nomor urut absen dalam rombel',
  `tanggal_masuk` date NOT NULL COMMENT 'Tanggal masuk ke rombel ini',
  `tanggal_keluar` date DEFAULT NULL COMMENT 'Tanggal keluar dari rombel',
  `status` enum('aktif','pindah','lulus','keluar') NOT NULL DEFAULT 'aktif',
  `catatan` text DEFAULT NULL COMMENT 'Catatan khusus terkait anggota rombel',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_siswa_rombel_tanggal` (`rombongan_belajar_id`,`siswa_id`,`tanggal_masuk`),
  KEY `anggota_rombels_rombongan_belajar_id_status_index` (`rombongan_belajar_id`,`status`),
  KEY `anggota_rombels_siswa_id_index` (`siswa_id`),
  KEY `anggota_rombels_status_index` (`status`),
  CONSTRAINT `anggota_rombels_rombongan_belajar_id_foreign` FOREIGN KEY (`rombongan_belajar_id`) REFERENCES `rombongan_belajars` (`id`) ON DELETE CASCADE,
  CONSTRAINT `anggota_rombels_siswa_id_foreign` FOREIGN KEY (`siswa_id`) REFERENCES `siswas` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `asramas`
--

DROP TABLE IF EXISTS `asramas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `asramas` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `unit_id` bigint(20) unsigned NOT NULL COMMENT 'Unit pesantren',
  `kode_asrama` varchar(20) NOT NULL COMMENT 'Kode unik asrama: KOBONG-PUTRA, ASR-01',
  `nama_asrama` varchar(255) NOT NULL COMMENT 'Nama asrama: Kobong Putra, Gedung A',
  `jenis_kelamin` enum('L','P','campuran') NOT NULL COMMENT 'L=Putra, P=Putri, campuran=Campuran',
  `alamat` text DEFAULT NULL COMMENT 'Alamat lokasi asrama jika berbeda dengan unit',
  `ptk_id` bigint(20) unsigned DEFAULT NULL,
  `nama_wali_kelas` varchar(255) DEFAULT NULL,
  `kapasitas_total` smallint(5) unsigned DEFAULT NULL COMMENT 'Total kapasitas asrama (opsional)',
  `fasilitas` text DEFAULT NULL COMMENT 'Fasilitas asrama: AC, WiFi, Laundry, dll',
  `tata_tertib` text DEFAULT NULL COMMENT 'Tata tertib asrama',
  `status` enum('aktif','nonaktif','renovasi') NOT NULL DEFAULT 'aktif',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `asramas_unit_id_kode_asrama_unique` (`unit_id`,`kode_asrama`),
  KEY `asramas_unit_id_index` (`unit_id`),
  KEY `asramas_status_index` (`status`),
  KEY `asramas_jenis_kelamin_index` (`jenis_kelamin`),
  KEY `asramas_ptk_id_foreign` (`ptk_id`),
  CONSTRAINT `asramas_ptk_id_foreign` FOREIGN KEY (`ptk_id`) REFERENCES `ptk` (`id`) ON DELETE SET NULL,
  CONSTRAINT `asramas_unit_id_foreign` FOREIGN KEY (`unit_id`) REFERENCES `units` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cache`
--

DROP TABLE IF EXISTS `cache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` int(11) NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cache_locks`
--

DROP TABLE IF EXISTS `cache_locks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` int(11) NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `dokumen_siswas`
--

DROP TABLE IF EXISTS `dokumen_siswas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dokumen_siswas` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `siswa_id` bigint(20) unsigned NOT NULL,
  `jenis_dokumen` enum('foto','kk','akte_kelahiran','ijazah','skhun','ktp_ayah','ktp_ibu','ktp_wali','kartu_pkh','kartu_kks','kartu_kip','surat_pindah','surat_keterangan_lulus','rapor','sertifikat_prestasi','surat_keterangan_sehat','surat_pernyataan','lainnya') NOT NULL COMMENT 'Jenis dokumen yang diupload',
  `judul_dokumen` varchar(255) DEFAULT NULL COMMENT 'Judul/nama dokumen',
  `file_path` varchar(255) NOT NULL COMMENT 'Path ke file storage',
  `nama_file_asli` varchar(255) DEFAULT NULL,
  `mime_type` varchar(100) DEFAULT NULL,
  `ukuran_file_bytes` int(10) unsigned DEFAULT NULL COMMENT 'Ukuran file dalam bytes',
  `keterangan` text DEFAULT NULL,
  `tanggal_dokumen` date DEFAULT NULL COMMENT 'Tanggal terbit dokumen',
  `is_terverifikasi` tinyint(1) NOT NULL DEFAULT 0,
  `tanggal_verifikasi` timestamp NULL DEFAULT NULL,
  `verified_by_user_id` bigint(20) unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `dokumen_siswas_siswa_id_jenis_dokumen_index` (`siswa_id`,`jenis_dokumen`),
  KEY `dokumen_siswas_is_terverifikasi_index` (`is_terverifikasi`),
  KEY `dokumen_siswas_verified_by_user_id_foreign` (`verified_by_user_id`),
  CONSTRAINT `dokumen_siswas_siswa_id_foreign` FOREIGN KEY (`siswa_id`) REFERENCES `siswas` (`id`) ON DELETE CASCADE,
  CONSTRAINT `dokumen_siswas_verified_by_user_id_foreign` FOREIGN KEY (`verified_by_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `failed_jobs`
--

DROP TABLE IF EXISTS `failed_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `failed_jobs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) NOT NULL,
  `connection` text NOT NULL,
  `queue` text NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `job_batches`
--

DROP TABLE IF EXISTS `job_batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job_batches` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `total_jobs` int(11) NOT NULL,
  `pending_jobs` int(11) NOT NULL,
  `failed_jobs` int(11) NOT NULL,
  `failed_job_ids` longtext NOT NULL,
  `options` mediumtext DEFAULT NULL,
  `cancelled_at` int(11) DEFAULT NULL,
  `created_at` int(11) NOT NULL,
  `finished_at` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `jobs`
--

DROP TABLE IF EXISTS `jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `jobs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` tinyint(3) unsigned NOT NULL,
  `reserved_at` int(10) unsigned DEFAULT NULL,
  `available_at` int(10) unsigned NOT NULL,
  `created_at` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `jobs_queue_index` (`queue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `kamar_asramas`
--

DROP TABLE IF EXISTS `kamar_asramas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `kamar_asramas` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `asrama_id` bigint(20) unsigned NOT NULL,
  `nomor_kamar` varchar(20) NOT NULL COMMENT 'Nomor kamar: 101, 201, A1, dll',
  `nama_kamar` varchar(255) DEFAULT NULL COMMENT 'Nama kamar (opsional): Kamar Al-Fatih, Kamar Putih',
  `lantai` varchar(10) DEFAULT NULL COMMENT 'Lantai berapa: 1, 2, 3, Ground, dll',
  `kapasitas` tinyint(3) unsigned NOT NULL DEFAULT 4 COMMENT 'Kapasitas maksimal penghuni',
  `fasilitas` text DEFAULT NULL COMMENT 'AC, lemari, kasur, dll',
  `status` enum('tersedia','penuh','maintenance','ditutup') NOT NULL DEFAULT 'tersedia',
  `keterangan` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_nomor_kamar_per_asrama` (`asrama_id`,`nomor_kamar`),
  KEY `kamar_asramas_asrama_id_status_index` (`asrama_id`,`status`),
  KEY `kamar_asramas_status_index` (`status`),
  CONSTRAINT `kamar_asramas_asrama_id_foreign` FOREIGN KEY (`asrama_id`) REFERENCES `asramas` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `log_kenaikan_kelas`
--

DROP TABLE IF EXISTS `log_kenaikan_kelas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `log_kenaikan_kelas` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `unit_id` bigint(20) unsigned NOT NULL,
  `tahun_ajaran_dari_id` bigint(20) unsigned NOT NULL COMMENT 'Tahun ajaran asal',
  `tahun_ajaran_ke_id` bigint(20) unsigned NOT NULL COMMENT 'Tahun ajaran tujuan',
  `tingkat_dari` varchar(5) NOT NULL COMMENT 'Tingkat asal contoh: 10, X, 1',
  `tingkat_ke` varchar(5) NOT NULL COMMENT 'Tingkat tujuan contoh: 11, XI, 2',
  `tanggal_eksekusi` timestamp NOT NULL COMMENT 'Waktu proses kenaikan dijalankan',
  `jumlah_siswa_diproses` int(10) unsigned NOT NULL DEFAULT 0,
  `jumlah_berhasil` int(10) unsigned NOT NULL DEFAULT 0,
  `jumlah_gagal` int(10) unsigned NOT NULL DEFAULT 0,
  `jenis_kenaikan` enum('naik_kelas','lulus','tinggal_kelas') NOT NULL DEFAULT 'naik_kelas',
  `executed_by_user_id` bigint(20) unsigned NOT NULL COMMENT 'User yang menjalankan proses',
  `keterangan` text DEFAULT NULL,
  `detail_proses` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Detail siswa yang diproses' CHECK (json_valid(`detail_proses`)),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `log_kelas_idx` (`unit_id`,`tahun_ajaran_dari_id`,`tahun_ajaran_ke_id`),
  KEY `log_kelas_tgl_idx` (`tanggal_eksekusi`),
  KEY `log_kenaikan_kelas_tahun_ajaran_dari_id_foreign` (`tahun_ajaran_dari_id`),
  KEY `log_kenaikan_kelas_tahun_ajaran_ke_id_foreign` (`tahun_ajaran_ke_id`),
  KEY `log_kenaikan_kelas_executed_by_user_id_foreign` (`executed_by_user_id`),
  CONSTRAINT `log_kenaikan_kelas_executed_by_user_id_foreign` FOREIGN KEY (`executed_by_user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `log_kenaikan_kelas_tahun_ajaran_dari_id_foreign` FOREIGN KEY (`tahun_ajaran_dari_id`) REFERENCES `tahun_ajarans` (`id`) ON DELETE CASCADE,
  CONSTRAINT `log_kenaikan_kelas_tahun_ajaran_ke_id_foreign` FOREIGN KEY (`tahun_ajaran_ke_id`) REFERENCES `tahun_ajarans` (`id`) ON DELETE CASCADE,
  CONSTRAINT `log_kenaikan_kelas_unit_id_foreign` FOREIGN KEY (`unit_id`) REFERENCES `units` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `log_mutasi_asramas`
--

DROP TABLE IF EXISTS `log_mutasi_asramas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `log_mutasi_asramas` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `siswa_id` bigint(20) unsigned NOT NULL,
  `penempatan_asrama_id` bigint(20) unsigned NOT NULL,
  `kamar_asal_id` bigint(20) unsigned DEFAULT NULL COMMENT 'Kamar sebelum mutasi',
  `kamar_tujuan_id` bigint(20) unsigned NOT NULL COMMENT 'Kamar setelah mutasi',
  `tanggal_mutasi` date NOT NULL,
  `jenis_mutasi` enum('pindah_kamar','pindah_asrama','keluar') NOT NULL COMMENT 'Jenis mutasi yang dilakukan',
  `alasan` text DEFAULT NULL COMMENT 'Alasan mutasi',
  `diproses_oleh_user_id` bigint(20) unsigned NOT NULL COMMENT 'User yang memproses mutasi',
  `ip_address` varchar(45) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `log_mutasi_asramas_siswa_id_tanggal_mutasi_index` (`siswa_id`,`tanggal_mutasi`),
  KEY `log_mutasi_asramas_jenis_mutasi_index` (`jenis_mutasi`),
  KEY `log_mutasi_asramas_tanggal_mutasi_index` (`tanggal_mutasi`),
  KEY `log_mutasi_asramas_penempatan_asrama_id_foreign` (`penempatan_asrama_id`),
  KEY `log_mutasi_asramas_kamar_asal_id_foreign` (`kamar_asal_id`),
  KEY `log_mutasi_asramas_kamar_tujuan_id_foreign` (`kamar_tujuan_id`),
  KEY `log_mutasi_asramas_diproses_oleh_user_id_foreign` (`diproses_oleh_user_id`),
  CONSTRAINT `log_mutasi_asramas_diproses_oleh_user_id_foreign` FOREIGN KEY (`diproses_oleh_user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `log_mutasi_asramas_kamar_asal_id_foreign` FOREIGN KEY (`kamar_asal_id`) REFERENCES `kamar_asramas` (`id`) ON DELETE SET NULL,
  CONSTRAINT `log_mutasi_asramas_kamar_tujuan_id_foreign` FOREIGN KEY (`kamar_tujuan_id`) REFERENCES `kamar_asramas` (`id`) ON DELETE CASCADE,
  CONSTRAINT `log_mutasi_asramas_penempatan_asrama_id_foreign` FOREIGN KEY (`penempatan_asrama_id`) REFERENCES `penempatan_asramas` (`id`) ON DELETE CASCADE,
  CONSTRAINT `log_mutasi_asramas_siswa_id_foreign` FOREIGN KEY (`siswa_id`) REFERENCES `siswas` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `log_perubahan_siswas`
--

DROP TABLE IF EXISTS `log_perubahan_siswas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `log_perubahan_siswas` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `siswa_id` bigint(20) unsigned NOT NULL,
  `user_id` bigint(20) unsigned NOT NULL COMMENT 'User yang melakukan perubahan',
  `aksi` enum('create','update','delete','restore') NOT NULL COMMENT 'Jenis aksi yang dilakukan',
  `tabel_terkait` varchar(50) DEFAULT NULL COMMENT 'Tabel yang diubah: siswa, profil_siswa, wali_siswa, dll',
  `data_lama` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Data sebelum perubahan' CHECK (json_valid(`data_lama`)),
  `data_baru` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Data setelah perubahan' CHECK (json_valid(`data_baru`)),
  `keterangan` text DEFAULT NULL COMMENT 'Keterangan tambahan',
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `log_perubahan_siswas_siswa_id_created_at_index` (`siswa_id`,`created_at`),
  KEY `log_perubahan_siswas_user_id_created_at_index` (`user_id`,`created_at`),
  KEY `log_perubahan_siswas_aksi_index` (`aksi`),
  CONSTRAINT `log_perubahan_siswas_siswa_id_foreign` FOREIGN KEY (`siswa_id`) REFERENCES `siswas` (`id`) ON DELETE CASCADE,
  CONSTRAINT `log_perubahan_siswas_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `migrations` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `password_reset_tokens`
--

DROP TABLE IF EXISTS `password_reset_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pembimbing_asramas`
--

DROP TABLE IF EXISTS `pembimbing_asramas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pembimbing_asramas` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `asrama_id` bigint(20) unsigned NOT NULL,
  `tahun_ajaran_id` bigint(20) unsigned NOT NULL,
  `pembimbing_id` longtext NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `pembimbing_asramas_asrama_id_tahun_ajaran_id_index` (`asrama_id`,`tahun_ajaran_id`),
  KEY `pembimbing_asramas_tahun_ajaran_id_foreign` (`tahun_ajaran_id`),
  CONSTRAINT `pembimbing_asramas_asrama_id_foreign` FOREIGN KEY (`asrama_id`) REFERENCES `asramas` (`id`) ON DELETE CASCADE,
  CONSTRAINT `pembimbing_asramas_tahun_ajaran_id_foreign` FOREIGN KEY (`tahun_ajaran_id`) REFERENCES `tahun_ajarans` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `penempatan_asramas`
--

DROP TABLE IF EXISTS `penempatan_asramas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `penempatan_asramas` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `siswa_id` bigint(20) unsigned NOT NULL COMMENT 'Santri yang ditempatkan',
  `kamar_asrama_id` bigint(20) unsigned NOT NULL,
  `tahun_ajaran_id` bigint(20) unsigned NOT NULL,
  `tanggal_masuk` date NOT NULL COMMENT 'Tanggal check-in ke kamar',
  `tanggal_keluar` date DEFAULT NULL COMMENT 'Tanggal check-out dari kamar',
  `ptk_id` bigint(20) unsigned DEFAULT NULL,
  `nomor_tempat_tidur` varchar(10) DEFAULT NULL COMMENT 'Nomor tempat tidur: 1, 2, A, B, dll',
  `status` enum('aktif','pindah','keluar','lulus') NOT NULL DEFAULT 'aktif',
  `catatan` text DEFAULT NULL COMMENT 'Catatan khusus terkait penempatan',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `penempatan_asramas_siswa_id_tahun_ajaran_id_index` (`siswa_id`,`tahun_ajaran_id`),
  KEY `penempatan_asramas_kamar_asrama_id_status_index` (`kamar_asrama_id`,`status`),
  KEY `penempatan_asramas_status_index` (`status`),
  KEY `penempatan_asramas_tahun_ajaran_id_status_index` (`tahun_ajaran_id`,`status`),
  KEY `penempatan_asramas_ptk_id_foreign` (`ptk_id`),
  CONSTRAINT `penempatan_asramas_kamar_asrama_id_foreign` FOREIGN KEY (`kamar_asrama_id`) REFERENCES `kamar_asramas` (`id`) ON DELETE CASCADE,
  CONSTRAINT `penempatan_asramas_ptk_id_foreign` FOREIGN KEY (`ptk_id`) REFERENCES `ptk` (`id`) ON DELETE SET NULL,
  CONSTRAINT `penempatan_asramas_siswa_id_foreign` FOREIGN KEY (`siswa_id`) REFERENCES `siswas` (`id`) ON DELETE CASCADE,
  CONSTRAINT `penempatan_asramas_tahun_ajaran_id_foreign` FOREIGN KEY (`tahun_ajaran_id`) REFERENCES `tahun_ajarans` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `profil_siswas`
--

DROP TABLE IF EXISTS `profil_siswas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `profil_siswas` (
  `siswa_id` bigint(20) unsigned NOT NULL,
  `hobi` text DEFAULT NULL COMMENT 'Hobi siswa',
  `cita_cita` text DEFAULT NULL COMMENT 'Cita-cita siswa',
  `prestasi` text DEFAULT NULL COMMENT 'Prestasi yang pernah diraih',
  `moda_transportasi` varchar(50) DEFAULT NULL COMMENT 'Jalan kaki, sepeda, motor, mobil, angkot',
  `jarak_rumah_km` smallint(5) unsigned DEFAULT NULL COMMENT 'Jarak rumah ke sekolah dalam km',
  `waktu_tempuh_menit` smallint(5) unsigned DEFAULT NULL COMMENT 'Waktu tempuh dalam menit',
  `berkebutuhan_khusus` tinyint(1) NOT NULL DEFAULT 0,
  `jenis_kebutuhan_khusus` varchar(100) DEFAULT NULL COMMENT 'Tunanetra, Tunarungu, Tunagrahita, dll',
  `keterangan_kebutuhan_khusus` text DEFAULT NULL,
  `penerima_kip` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Kartu Indonesia Pintar',
  `nomor_kip` varchar(30) DEFAULT NULL,
  `penerima_pip` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Program Indonesia Pintar',
  `alasan_pip` text DEFAULT NULL,
  `riwayat_penyakit` text DEFAULT NULL COMMENT 'Riwayat penyakit yang pernah diderita',
  `alergi` text DEFAULT NULL COMMENT 'Alergi makanan/obat/lainnya',
  `tinggi_badan_cm` smallint(5) unsigned DEFAULT NULL COMMENT 'Tinggi badan dalam cm',
  `berat_badan_kg` smallint(5) unsigned DEFAULT NULL COMMENT 'Berat badan dalam kg',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`siswa_id`),
  CONSTRAINT `profil_siswas_siswa_id_foreign` FOREIGN KEY (`siswa_id`) REFERENCES `siswas` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ptk`
--

DROP TABLE IF EXISTS `ptk`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ptk` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `nama` varchar(255) NOT NULL,
  `niy` varchar(255) NOT NULL,
  `no_hp` varchar(255) NOT NULL,
  `penugasan` varchar(255) NOT NULL,
  `alamat` varchar(255) NOT NULL,
  `tahun_ajaran_id` bigint(20) unsigned NOT NULL,
  `tanggal_mulai` date NOT NULL,
  `tanggal_selesai` date DEFAULT NULL,
  `status` enum('aktif','nonaktif') NOT NULL DEFAULT 'aktif',
  `keterangan` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ptk_tahun_ajaran_id_foreign` (`tahun_ajaran_id`),
  CONSTRAINT `ptk_tahun_ajaran_id_foreign` FOREIGN KEY (`tahun_ajaran_id`) REFERENCES `tahun_ajarans` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `rombongan_belajars`
--

DROP TABLE IF EXISTS `rombongan_belajars`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rombongan_belajars` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `unit_id` bigint(20) unsigned NOT NULL,
  `tahun_ajaran_id` bigint(20) unsigned NOT NULL,
  `kode_rombel` varchar(20) NOT NULL COMMENT 'Contoh: X-IPA-1, 10-A, VII-1',
  `nama_rombel` varchar(255) NOT NULL COMMENT 'Contoh: X IPA 1, Kelas 10 A, VII-1',
  `tingkat` varchar(5) NOT NULL COMMENT 'Tingkat: 1,2,3 atau 7,8,9 atau 10,11,12 atau X,XI,XII',
  `jurusan` varchar(50) DEFAULT NULL COMMENT 'IPA, IPS, Bahasa, Agama (untuk SMA/MA), TKJ, RPL (untuk SMK)',
  `wali_kelas_id` varchar(50) DEFAULT NULL COMMENT 'ID Wali Kelas, bisa dari PTK service atau sementara string nama',
  `nama_wali_kelas` varchar(255) DEFAULT NULL COMMENT 'Nama wali kelas untuk ditampilkan',
  `kapasitas_maksimal` tinyint(3) unsigned NOT NULL DEFAULT 30 COMMENT 'Kapasitas maksimal siswa',
  `ruangan` varchar(50) DEFAULT NULL COMMENT 'Nama/nomor ruangan kelas',
  `status` enum('aktif','nonaktif') NOT NULL DEFAULT 'aktif',
  `keterangan` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_rombel_per_unit_tahun` (`unit_id`,`tahun_ajaran_id`,`kode_rombel`),
  KEY `rombongan_belajars_unit_id_tahun_ajaran_id_index` (`unit_id`,`tahun_ajaran_id`),
  KEY `rombongan_belajars_status_index` (`status`),
  KEY `rombongan_belajars_tingkat_index` (`tingkat`),
  CONSTRAINT `rombongan_belajars_tahun_ajaran_id_foreign` FOREIGN KEY (`tahun_ajaran_id`) REFERENCES `tahun_ajarans` (`id`) ON DELETE CASCADE,
  CONSTRAINT `rombongan_belajars_unit_id_foreign` FOREIGN KEY (`unit_id`) REFERENCES `units` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sekolah_asals`
--

DROP TABLE IF EXISTS `sekolah_asals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sekolah_asals` (
  `siswa_id` bigint(20) unsigned NOT NULL,
  `nama_sekolah` varchar(255) NOT NULL,
  `npsn` varchar(8) DEFAULT NULL COMMENT 'Nomor Pokok Sekolah Nasional',
  `nss` varchar(12) DEFAULT NULL COMMENT 'Nomor Statistik Sekolah',
  `jenjang` enum('TK','SD','MI','SMP','MTs','SMA','MA','SMK','Paket A','Paket B','Paket C') NOT NULL,
  `status_sekolah` enum('negeri','swasta') DEFAULT NULL,
  `alamat_sekolah` text NOT NULL,
  `kecamatan` varchar(255) DEFAULT NULL,
  `kabupaten_kota` varchar(255) DEFAULT NULL,
  `provinsi` varchar(255) DEFAULT NULL,
  `nomor_peserta_ujian` varchar(50) DEFAULT NULL COMMENT 'Nomor peserta UN/USBN',
  `nomor_seri_ijazah` varchar(50) DEFAULT NULL,
  `tanggal_lulus` date DEFAULT NULL,
  `tahun_lulus` year(4) DEFAULT NULL,
  `nilai_ujian` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Format: {"matematika": 85, "bahasa_indonesia": 90, "ipa": 88}' CHECK (json_valid(`nilai_ujian`)),
  `rata_rata_nilai` decimal(5,2) DEFAULT NULL COMMENT 'Rata-rata nilai ujian',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`siswa_id`),
  CONSTRAINT `sekolah_asals_siswa_id_foreign` FOREIGN KEY (`siswa_id`) REFERENCES `siswas` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` bigint(20) unsigned DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` longtext NOT NULL,
  `last_activity` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sessions_user_id_index` (`user_id`),
  KEY `sessions_last_activity_index` (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `siswas`
--

DROP TABLE IF EXISTS `siswas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `siswas` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `unit_id` bigint(20) unsigned NOT NULL,
  `user_id` bigint(20) unsigned DEFAULT NULL COMMENT 'Untuk akses login siswa di masa depan',
  `nis` varchar(20) NOT NULL COMMENT 'Nomor Induk Siswa - auto generate',
  `nis_madrasah` varchar(20) DEFAULT NULL,
  `nisn` varchar(10) DEFAULT NULL COMMENT 'Nomor Induk Siswa Nasional',
  `nomor_registrasi_ppdb` varchar(30) DEFAULT NULL COMMENT 'Nomor registrasi dari PSB',
  `status_siswa` enum('aktif','lulus','pindah','keluar','cuti') NOT NULL DEFAULT 'aktif',
  `status_pendaftaran` enum('siswa_baru','mutasi_masuk') DEFAULT NULL,
  `tanggal_masuk` date NOT NULL,
  `tanggal_lulus` date DEFAULT NULL,
  `tahun_masuk` year(4) NOT NULL COMMENT 'Untuk filter dan grouping',
  `nama_lengkap` varchar(255) NOT NULL,
  `nama_panggilan` varchar(50) DEFAULT NULL,
  `nik` varchar(16) DEFAULT NULL COMMENT 'Nomor Induk Kependudukan',
  `tempat_lahir` varchar(255) NOT NULL,
  `tanggal_lahir` date NOT NULL,
  `jenis_kelamin` enum('L','P') NOT NULL,
  `golongan_darah` enum('A','B','AB','O') DEFAULT NULL,
  `agama` varchar(20) DEFAULT NULL,
  `kewarganegaraan` varchar(50) NOT NULL DEFAULT 'Indonesia',
  `email` varchar(100) DEFAULT NULL,
  `nomor_hp` varchar(15) DEFAULT NULL,
  `alamat_lengkap` text NOT NULL,
  `rt` varchar(3) DEFAULT NULL,
  `rw` varchar(3) DEFAULT NULL,
  `kelurahan` varchar(255) NOT NULL,
  `kecamatan` varchar(255) NOT NULL,
  `kabupaten_kota` varchar(255) NOT NULL,
  `provinsi` varchar(255) NOT NULL,
  `kode_pos` varchar(5) DEFAULT NULL,
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `nomor_kk` varchar(16) DEFAULT NULL COMMENT 'Nomor Kartu Keluarga',
  `nomor_pkh` varchar(30) DEFAULT NULL COMMENT 'Program Keluarga Harapan',
  `nomor_kks` varchar(30) DEFAULT NULL COMMENT 'Kartu Keluarga Sejahtera',
  `anak_ke` tinyint(3) unsigned DEFAULT NULL,
  `jumlah_saudara` tinyint(3) unsigned DEFAULT NULL,
  `foto` varchar(255) DEFAULT NULL COMMENT 'Path file foto',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `siswas_nis_unique` (`nis`),
  UNIQUE KEY `siswas_nis_madrasah_unique` (`nis_madrasah`),
  UNIQUE KEY `siswas_nisn_unique` (`nisn`),
  UNIQUE KEY `siswas_nik_unique` (`nik`),
  KEY `siswas_unit_id_index` (`unit_id`),
  KEY `siswas_status_siswa_index` (`status_siswa`),
  KEY `siswas_tahun_masuk_index` (`tahun_masuk`),
  KEY `siswas_nama_lengkap_tanggal_lahir_index` (`nama_lengkap`,`tanggal_lahir`),
  KEY `siswas_jenis_kelamin_index` (`jenis_kelamin`),
  KEY `siswas_user_id_foreign` (`user_id`),
  CONSTRAINT `siswas_unit_id_foreign` FOREIGN KEY (`unit_id`) REFERENCES `units` (`id`) ON DELETE CASCADE,
  CONSTRAINT `siswas_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tahun_ajarans`
--

DROP TABLE IF EXISTS `tahun_ajarans`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tahun_ajarans` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `unit_id` bigint(20) unsigned NOT NULL,
  `nama` varchar(20) NOT NULL COMMENT 'Format: 2024/2025',
  `tahun_mulai` year(4) NOT NULL COMMENT 'Tahun mulai: 2024',
  `tahun_selesai` year(4) NOT NULL COMMENT 'Tahun selesai: 2025',
  `semester` enum('1','2','3','4','5','6') NOT NULL DEFAULT '1',
  `tanggal_mulai` date NOT NULL,
  `tanggal_selesai` date NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Hanya 1 tahun ajaran aktif per unit',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `tahun_ajarans_unit_id_nama_semester_unique` (`unit_id`,`nama`,`semester`),
  KEY `tahun_ajarans_unit_id_is_active_index` (`unit_id`,`is_active`),
  CONSTRAINT `tahun_ajarans_unit_id_foreign` FOREIGN KEY (`unit_id`) REFERENCES `units` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `units`
--

DROP TABLE IF EXISTS `units`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `units` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `kode_unit` varchar(20) NOT NULL COMMENT 'Kode unik unit/sekolah',
  `nama_unit` varchar(255) NOT NULL COMMENT 'Nama unit/sekolah',
  `jenis_unit` enum('formal','pesantren') NOT NULL DEFAULT 'formal' COMMENT 'Jenis unit: formal atau pesantren',
  `npsn` varchar(8) DEFAULT NULL COMMENT 'Nomor Pokok Sekolah Nasional',
  `nss` varchar(12) DEFAULT NULL COMMENT 'Nomor Statistik Sekolah',
  `jenjang` enum('TK','SD','SMP','SMA','SMK','MA') NOT NULL COMMENT 'Jenjang pendidikan',
  `status_unit` enum('negeri','swasta') NOT NULL DEFAULT 'swasta',
  `alamat` text NOT NULL,
  `kelurahan` varchar(255) NOT NULL,
  `kecamatan` varchar(255) NOT NULL,
  `kabupaten_kota` varchar(255) NOT NULL,
  `provinsi` varchar(255) NOT NULL,
  `kode_pos` varchar(5) DEFAULT NULL,
  `telepon` varchar(15) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `website` varchar(255) DEFAULT NULL,
  `nama_kepala_sekolah` varchar(255) DEFAULT NULL COMMENT 'Nama Kepala Sekolah atau Pengasuh Pesantren',
  `nip_kepala_sekolah` varchar(18) DEFAULT NULL,
  `kop_surat` varchar(255) DEFAULT NULL COMMENT 'Path file kop surat',
  `logo` varchar(255) DEFAULT NULL COMMENT 'Path file logo',
  `status` enum('aktif','nonaktif') NOT NULL DEFAULT 'aktif',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `units_kode_unit_unique` (`kode_unit`),
  KEY `units_status_index` (`status`),
  KEY `units_jenjang_index` (`jenjang`),
  KEY `units_jenis_unit_index` (`jenis_unit`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `unit_id` bigint(20) unsigned DEFAULT NULL COMMENT 'Null untuk superadmin',
  `role` enum('superadmin','admin_unit','kepala_unit','admin_pesantren') NOT NULL DEFAULT 'admin_unit',
  `status` enum('aktif','nonaktif') NOT NULL DEFAULT 'aktif',
  `last_login_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`),
  KEY `users_unit_id_role_index` (`unit_id`,`role`),
  KEY `users_status_index` (`status`),
  CONSTRAINT `users_unit_id_foreign` FOREIGN KEY (`unit_id`) REFERENCES `units` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `wali_siswas`
--

DROP TABLE IF EXISTS `wali_siswas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `wali_siswas` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `siswa_id` bigint(20) unsigned NOT NULL,
  `hubungan` enum('ayah','ibu','wali','kakak','paman','bibi','kakek','nenek','lainnya') NOT NULL,
  `is_wali_utama` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Wali utama yang akan dihubungi',
  `nama` varchar(255) NOT NULL,
  `nik` varchar(16) DEFAULT NULL COMMENT 'Nomor Induk Kependudukan',
  `tempat_lahir` varchar(255) DEFAULT NULL,
  `tanggal_lahir` date DEFAULT NULL,
  `jenis_kelamin` enum('L','P') DEFAULT NULL,
  `agama` varchar(20) DEFAULT NULL,
  `pendidikan_terakhir` varchar(50) DEFAULT NULL COMMENT 'Tidak Sekolah, SD, SMP, SMA, D1, D2, D3, D4, S1, S2, S3',
  `pekerjaan` varchar(100) DEFAULT NULL,
  `jabatan` varchar(100) DEFAULT NULL,
  `nama_perusahaan` varchar(150) DEFAULT NULL,
  `penghasilan_bulanan` varchar(50) DEFAULT NULL COMMENT '< 1 juta, 1-2 juta, 2-5 juta, 5-10 juta, > 10 juta',
  `nomor_hp` varchar(15) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `alamat_sama_dengan_siswa` tinyint(1) NOT NULL DEFAULT 1,
  `alamat_lengkap` text DEFAULT NULL COMMENT 'Diisi jika berbeda dengan siswa',
  `status_hidup` tinyint(1) NOT NULL DEFAULT 1,
  `status` enum('aktif','nonaktif','meninggal') NOT NULL DEFAULT 'aktif',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `wali_siswas_siswa_id_is_wali_utama_index` (`siswa_id`,`is_wali_utama`),
  KEY `wali_siswas_siswa_id_hubungan_index` (`siswa_id`,`hubungan`),
  CONSTRAINT `wali_siswas_siswa_id_foreign` FOREIGN KEY (`siswa_id`) REFERENCES `siswas` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-01-05 13:23:44
--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `migrations` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `migrations`
--

LOCK TABLES `migrations` WRITE;
/*!40000 ALTER TABLE `migrations` DISABLE KEYS */;
INSERT INTO `migrations` VALUES (1, '0001_01_01_000000_create_users_table', 1),(2, '0001_01_01_000001_create_cache_table', 1),(3, '0001_01_01_000002_create_jobs_table', 1),(4, '2025_11_29_191326_create_units_table', 1),(5, '2025_11_29_191420_create_tahun_ajarans_table', 1),(6, '2025_11_29_191450_update_users', 1),(7, '2025_11_29_191512_create_siswas_table', 1),(8, '2025_11_29_191531_create_profil_siswas_table', 1),(9, '2025_11_29_191550_create_wali_siswas_table', 1),(10, '2025_11_29_191605_create_sekolah_asals_table', 1),(11, '2025_11_29_191627_create_dokumen_siswas_table', 1),(12, '2025_11_29_191648_create_rombongan_belajars_table', 1),(13, '2025_11_29_191702_create_anggota_rombels_table', 1),(14, '2025_11_29_191714_create_asramas_table', 1),(15, '2025_11_29_191725_create_kamar_asramas_table', 1),(16, '2025_11_29_191738_create_penempatan_asramas_table', 1),(17, '2025_11_29_191749_create_pembimbing_asramas_table', 1),(18, '2025_11_29_191815_create_log_kenaikan_kelas_table', 1),(19, '2025_11_29_191827_create_log_perubahan_siswas_table', 1),(20, '2025_11_29_191842_create_log_mutasi_asramas_table', 1),(21, '2025_12_06_124602_update_semester_enum_in_tahun_ajarans_table', 1),(22, '2025_12_06_141112_update_pembimbing_asrama_add_table_ptk', 1),(23, '2025_12_13_052931_update_asramas_table_for_ptk', 1),(24, '2025_12_13_070118_update_penempatan_asrama_to_use_ptk', 1),(25, '2026_01_03_175005_add_role_admin_pesantren_on_users', 1);
/*!40000 ALTER TABLE `migrations` ENABLE KEYS */;
UNLOCK TABLES;