<?php
// config.php
$host = "localhost";
$username = "root";  // Ganti dengan username dari cPanel
$password = "123456789"; // Ganti dengan password dari cPanel  
$database = "toko_stationery";  // Ganti dengan nama database dari cPanel

$conn = new mysqli($host, $username, $password, $database);

if ($conn->connect_error) {
    die("Koneksi gagal: " . $conn->connect_error);
}
?>
