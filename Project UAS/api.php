<?php
// api.php
require_once 'config.php';

// Set headers
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Get request data
$method = $_SERVER['REQUEST_METHOD'];
$input = json_decode(file_get_contents('php://input'), true);
$endpoint = $_GET['endpoint'] ?? '';

// Handle preflight
if ($method === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Routing
switch ($endpoint) {
    case 'produk':
        handleProduk($method, $input, $conn);
        break;
    case 'login':
        handleLogin($input, $conn);
        break;
    default:
        http_response_code(404);
        echo json_encode(['status' => 'error', 'message' => 'Endpoint not found']);
}

function handleProduk($method, $data, $conn) {
    switch ($method) {
        case 'GET':
            getProduk($conn);
            break;
        case 'POST':
            addProduk($data, $conn);
            break;
        case 'PUT':
            updateProduk($data, $conn);
            break;
        case 'DELETE':
            deleteProduk($data, $conn);
            break;
        default:
            http_response_code(405);
            echo json_encode(['status' => 'error', 'message' => 'Method not allowed']);
    }
}

function getProduk($conn) {
    $search = $_GET['search'] ?? '';
    $sql = "SELECT * FROM produk";
    
    if ($search) {
        $sql .= " WHERE nama_produk LIKE ? OR id_produk LIKE ?";
        $stmt = $conn->prepare($sql);
        $searchTerm = "%$search%";
        $stmt->bind_param("ss", $searchTerm, $searchTerm);
    } else {
        $stmt = $conn->prepare($sql);
    }
    
    $stmt->execute();
    $result = $stmt->get_result();
    $produk = $result->fetch_all(MYSQLI_ASSOC);
    
    echo json_encode(['status' => 'success', 'data' => $produk]);
}

function addProduk($data, $conn) {
    if (empty($data['id_produk']) || empty($data['nama_produk'])) {
        http_response_code(400);
        echo json_encode(['status' => 'error', 'message' => 'Data tidak lengkap']);
        return;
    }
    
    $stmt = $conn->prepare("INSERT INTO produk (id_produk, nama_produk, harga, stok) VALUES (?, ?, ?, ?)");
    $stmt->bind_param("ssii", 
        $data['id_produk'],
        $data['nama_produk'],
        $data['harga'],
        $data['stok']
    );
    
    if ($stmt->execute()) {
        echo json_encode(['status' => 'success', 'message' => 'Produk berhasil ditambahkan']);
    } else {
        http_response_code(500);
        echo json_encode(['status' => 'error', 'message' => 'Gagal menambahkan produk']);
    }
}

function updateProduk($data, $conn) {
    $stmt = $conn->prepare("UPDATE produk SET nama_produk = ?, harga = ?, stok = ? WHERE id_produk = ?");
    $stmt->bind_param("siis",
        $data['nama_produk'],
        $data['harga'],
        $data['stok'],
        $data['id_produk']
    );
    
    if ($stmt->execute()) {
        echo json_encode(['status' => 'success', 'message' => 'Produk berhasil diupdate']);
    } else {
        http_response_code(500);
        echo json_encode(['status' => 'error', 'message' => 'Gagal mengupdate produk']);
    }
}

function deleteProduk($data, $conn) {
    $stmt = $conn->prepare("DELETE FROM produk WHERE id_produk = ?");
    $stmt->bind_param("s", $data['id_produk']);
    
    if ($stmt->execute()) {
        echo json_encode(['status' => 'success', 'message' => 'Produk berhasil dihapus']);
    } else {
        http_response_code(500);
        echo json_encode(['status' => 'error', 'message' => 'Gagal menghapus produk']);
    }
}

function handleLogin($data, $conn) {
    // Demo login sederhana
    if ($data['role'] === 'admin' && $data['username'] === 'admin' && $data['password'] === 'admin123') {
        echo json_encode([
            'status' => 'success',
            'data' => [
                'id' => 1,
                'username' => 'admin',
                'email' => 'admin@stationery.com',
                'role' => 'admin'
            ]
        ]);
    } elseif ($data['role'] === 'pembeli' && $data['password'] === 'pembeli') {
        echo json_encode([
            'status' => 'success',
            'data' => [
                'id' => 2,
                'username' => $data['username'],
                'email' => $data['username'],
                'role' => 'pembeli'
            ]
        ]);
    } else {
        http_response_code(401);
        echo json_encode(['status' => 'error', 'message' => 'Login gagal']);
    }
}

$conn->close();
?>
