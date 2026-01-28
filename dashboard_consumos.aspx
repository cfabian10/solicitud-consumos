<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard de Consumos Corporativos</title>

    <!-- Fuentes & Iconos -->
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>

    <!-- Librerías de Datos y Gráficos -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chartjs-plugin-datalabels@2.0.0"></script>

    <style>
        :root {
            /* 🎨 PALETA OFICIAL */
            --col-blue-main: #0056A4;
            --col-blue-dark: #003A70;
            --col-blue-light: #4A90D9;
            --col-yellow: #F5B400;
            --col-white: #FFFFFF;
            --col-gray-light: #E6E6E6;
            --col-text: #4D4D4D;
            --col-green: #2ECC71;
            --col-red: #E74C3C;

            /* MAPPING TO UI VARS */
            --primary: var(--col-blue-main);
            --dark: var(--col-blue-dark);
            --bg-body: #F4F6F8;
            --bg-card: var(--col-white);
            --text-muted: #7F8C8D;
            --shadow: 0 4px 12px rgba(0, 58, 112, 0.08);
            --radius: 12px;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Roboto', sans-serif;
        }

        body {
            background-color: var(--bg-body);
            color: var(--col-text);
            margin: 0;
            display: flex;
            height: 100vh;
            overflow: hidden;
        }

        /* 🟦 SIDEBAR */
        aside {
            width: 280px;
            background: white;
            display: flex;
            flex-direction: column;
            border-right: 1px solid #EAEAEA;
            z-index: 100;
            padding-bottom: 20px;
            overflow-y: auto;
        }

        .logo-area {
            height: 90px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-bottom: 1px solid #F5F5F5;
            padding: 0 20px;
            background: #fff;
        }

        /* KPI COLUMN IN SIDEBAR */
        .kpi-row {
            display: flex;
            flex-direction: column;
            gap: 10px;
            padding: 15px;
        }

        .kpi-card {
            background: #FAFAFA;
            border: 1px solid #EEE;
            border-radius: 8px;
            padding: 12px;
            display: flex;
            align-items: center;
            gap: 12px;
            width: 100%;
        }

        .icon-box {
            width: 40px;
            height: 40px;
            font-size: 1.2rem;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .kpi-info h3 {
            font-size: 1.1rem;
            margin: 0;
            font-weight: 700;
            color: var(--dark);
        }

        .kpi-info p {
            font-size: 0.75rem;
            margin: 0;
            text-transform: uppercase;
            color: var(--text-muted);
            letter-spacing: 0.5px;
        }

        /* COLORS UTILS */
        .bg-blue-opt {
            background: #E6F0FA;
            color: var(--primary);
        }

        .bg-cyan-opt {
            background: #E0F7FA;
            color: #17A2B8;
        }

        .bg-yellow-opt {
            background: #FFF8E1;
            color: var(--col-yellow);
        }

        .bg-green-opt {
            background: #E9F7EF;
            color: var(--col-green);
        }

        /* ⬜ MAIN CONTENT */
        main {
            flex: 1;
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }

        /* 🔝 HEADER */
        header {
            height: 80px;
            background: white;
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 0 40px;
            box-shadow: var(--shadow);
            z-index: 50;
        }

        .page-header h2 {
            font-size: 1.4rem;
            color: var(--dark);
            font-weight: 700;
        }

        .header-actions {
            display: flex;
            align-items: center;
            gap: 20px;
        }

        /* COMPANY FILTER SELECT */
        .company-select-container {
            position: relative;
        }

        .company-select {
            appearance: none;
            background: #F4F6F9;
            border: 1px solid #E0E0E0;
            padding: 10px 40px 10px 20px;
            border-radius: 50px;
            color: var(--dark);
            font-weight: 600;
            font-size: 0.9rem;
            cursor: pointer;
            outline: none;
            min-width: 250px;
            box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.02);
            transition: all 0.2s;
        }

        .company-select:hover {
            background: #EDEDED;
            border-color: #CCC;
        }

        .company-select-icon {
            position: absolute;
            right: 15px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--primary);
            pointer-events: none;
        }

        .upload-btn {
            background: var(--primary);
            color: white;
            border: none;
            padding: 10px 25px;
            border-radius: 50px;
            font-weight: 600;
            cursor: pointer;
            box-shadow: 0 4px 10px rgba(0, 86, 164, 0.3);
            display: flex;
            align-items: center;
            gap: 10px;
            transition: background 0.2s;
        }

        .upload-btn:hover {
            background: var(--dark);
        }

        /* 📊 DASHBOARD CONTENT */
        .dashboard-container {
            padding: 30px;
            overflow-y: auto;
            height: calc(100vh - 80px);
            display: none;
            /* Hidden until data loaded */
        }

        .dashboard-container.active {
            display: block;
        }

        .charts-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 25px;
            margin-bottom: 25px;
        }

        .charts-grid.full-width {
            grid-template-columns: 1fr;
        }

        .charts-grid.ues-cards {
            grid-template-columns: repeat(3, 1fr);
            /* 3 cards per row */
            gap: 20px;
        }

        .chart-card {
            background: white;
            border-radius: var(--radius);
            padding: 20px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
            display: flex;
            flex-direction: column;
            min-height: 200px;
        }

        .chart-card.mini {
            height: auto;
            min-height: 120px;
        }

        .chart-header {
            margin-bottom: 15px;
            border-bottom: 1px solid #F0F0F0;
            padding-bottom: 10px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .chart-title {
            font-size: 0.95rem;
            font-weight: 700;
            color: var(--dark);
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .chart-body {
            flex: 1;
            position: relative;
            min-height: 0;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        /* UES CARD STYLES */
        .ues-card-content {
            display: flex;
            flex-direction: column;
            gap: 5px;
            width: 100%;
        }

        .ues-metric {
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 0.9rem;
            color: #666;
            padding: 5px 0;
            border-bottom: 1px dashed #eee;
        }

        .ues-metric:last-child {
            border-bottom: none;
        }

        .ues-value {
            font-weight: 700;
            color: var(--primary);
            font-size: 1.1rem;
        }

        /* SPLASH SCREEN */
        #splash {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(255, 255, 255, 0.95);
            z-index: 200;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
        }

        /* TABLA DE DETALLES */
        .table-container {
            margin-top: 20px;
            background: white;
            border-radius: var(--radius);
            padding: 20px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        th {
            text-align: left;
            padding: 12px;
            font-size: 0.8rem;
            color: var(--text-muted);
            border-bottom: 1px solid #EEE;
        }

        td {
            padding: 12px;
            font-size: 0.9rem;
            color: var(--dark);
            border-bottom: 1px solid #F9F9F9;
        }

        tr:hover {
            background: #FAFAFA;
        }
    </style>
</head>

<body>

    <!-- SIDEBAR -->
    <aside>
        <div class="logo-area">
            <h2 style="color:var(--primary); font-weight:900; font-size:1.5rem;">CONSUMOS</h2>
        </div>

        <div class="kpi-row">
            <!-- KPI Globales de la Empresa Seleccionada -->
            <div class="sidebar-section-title"
                style="font-size:0.75rem; color:#999; font-weight:700; margin:10px 0 5px 0;">KPIs CORPORATIVOS</div>

            <!-- Total Ventas -->
            <div class="kpi-card">
                <div class="icon-box bg-blue-opt"><i class="fa-solid fa-dollar-sign"></i></div>
                <div class="kpi-info">
                    <h3 id="kpi-ventas">$0</h3>
                    <p>Total Ventas</p>
                </div>
            </div>

            <!-- Total Usos -->
            <div class="kpi-card">
                <div class="icon-box bg-cyan-opt"><i class="fa-solid fa-ticket"></i></div>
                <div class="kpi-info">
                    <h3 id="kpi-usos">0</h3>
                    <p>Total Usos</p>
                </div>
            </div>

            <!-- Personas Únicas -->
            <div class="kpi-card">
                <div class="icon-box bg-yellow-opt"><i class="fa-solid fa-users"></i></div>
                <div class="kpi-info">
                    <h3 id="kpi-personas">0</h3>
                    <p>Personas Únicas</p>
                </div>
            </div>

        </div>
    </aside>

    <!-- MAIN -->
    <main>
        <header>
            <div class="page-header">
                <h2>Tablero de Control</h2>
                <div style="font-size:0.75rem; color:var(--text-muted);">Vista detallada por Empresa</div>
            </div>

            <div class="header-actions">
                <!-- SELECTOR DE EMPRESA -->
                <div class="company-select-container">
                    <select id="companySelect" class="company-select" disabled>
                        <option value="">Cargue datos primero...</option>
                    </select>
                    <i class="fa-solid fa-chevron-down company-select-icon"></i>
                </div>

                <!-- CARGAR DATOS -->
                <input type="file" id="fileInput" hidden accept=".csv, .xlsx, .xls">
                <button class="upload-btn" onclick="document.getElementById('fileInput').click()">
                    <i class="fa-solid fa-cloud-arrow-up"></i> Cargar Datos
                </button>
            </div>
        </header>

        <!-- PANTALLA DE CARGA / BIENVENIDA -->
        <div id="splash">
            <h1 style="color:var(--primary); margin-bottom:10px;">Dashboard de Consumos</h1>
            <p style="color:#777; margin-bottom:20px;">Por favor cargue el archivo <b>Consumos.csv</b> o Excel para
                comenzar.</p>
            <button class="upload-btn" onclick="document.getElementById('fileInput').click()">
                <i class="fa-solid fa-upload"></i> Seleccionar Archivo
            </button>
        </div>

        <!-- CONTENIDO DASHBOARD -->
        <div id="dashboard" class="dashboard-container">

            <!-- FILA 1: PIE CHART (Global) + COMPORTAMIENTO -->
            <div class="charts-grid" style="grid-template-columns: 1fr 2fr;">
                <!-- Distribución por Unidad de Negocio (UES) -->
                <div class="chart-card" style="height: 350px;">
                    <div class="chart-header">
                        <div class="chart-title">Distribución por UES</div>
                    </div>
                    <div class="chart-body"><canvas id="chart-ues"></canvas></div>
                </div>

                <!-- Tendencia Mensual (Global) -->
                <div class="chart-card" style="height: 350px;">
                    <div class="chart-header">
                        <div class="chart-title">Comportamiento Mensual (Global)</div>
                        <i class="fa-solid fa-chart-line" style="color:var(--primary);"></i>
                    </div>
                    <div class="chart-body"><canvas id="chart-mensual"></canvas></div>
                </div>
            </div>

            <!-- SECCIÓN: DETALLE POR UES (TARJETAS) -->
            <h3
                style="color:var(--dark); font-size:1.2rem; font-weight:700; margin-bottom:15px; border-left:4px solid var(--primary); padding-left:10px;">
                Secciones por Unidad de Negocio
            </h3>

            <div id="ues-container" class="charts-grid ues-cards">
                <!-- JS Inject Cards Here -->
            </div>

            <!-- TENDENCIA POR UES (Opcional, nueva row) -->
            <!-- Se quitó la tabla de sedes -->

        </div>
    </main>


    <style>
        /* ESTILOS DEL MODAL */
        .modal-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
            z-index: 1000;
            justify-content: center;
            align-items: center;
        }

        .modal-overlay.active {
            display: flex;
        }

        .modal-content {
            background: white;
            padding: 2rem;
            border-radius: 12px;
            width: 90%;
            max-width: 600px;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
            position: relative;
        }

        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.5rem;
            border-bottom: 1px solid #eee;
            padding-bottom: 1rem;
        }

        .close-modal {
            background: none;
            border: none;
            font-size: 1.5rem;
            cursor: pointer;
            color: #666;
        }

        .detail-table {
            width: 100%;
            border-collapse: collapse;
        }

        .detail-table th,
        .detail-table td {
            text-align: left;
            padding: 10px;
            border-bottom: 1px solid #eee;
        }

        .detail-table th {
            font-weight: 600;
            color: #555;
            background: #f9f9f9;
        }

        .clickable-metric {
            cursor: pointer;
            text-decoration: underline;
            text-decoration-style: dotted;
        }

        .clickable-metric:hover {
            color: #0056A4 !important;
            background-color: rgba(0, 0, 0, 0.05);
            border-radius: 4px;
        }
    </style>

    <!-- MODAL STRUCTURE -->
    <div id="detailModal" class="modal-overlay">
        <div class="modal-content">
            <div class="modal-header">
                <h2 id="modalTitle" style="margin:0; color:#0056A4;">Detalle</h2>
                <button class="close-modal" onclick="closeModal()">&times;</button>
            </div>
            <div style="max-height: 400px; overflow-y: auto;">
                <table class="detail-table">
                    <thead>
                        <tr>
                            <th>Sede / Lugar</th>
                            <th style="text-align:right">Usos</th>
                            <th style="text-align:right">Ventas</th>
                        </tr>
                    </thead>
                    <tbody id="modalBody">
                        <!-- Content here -->
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <script>
        // VARIABLES GLOBALES
        let rawData = [];
        let companies = [];
        let charts = {}; // Store Chart instances
        let currentUESStats = {}; // Para guardar el detalle actual

        /* =========================================
           1. CARGA DE DATOS (MODO TEXTO SIMPLIFICADO)
           ========================================= */
        /* =========================================
           1. CARGA DE DATOS (MÚLTIPLES ARCHIVOS)
           ========================================= */
        const fileInput = document.getElementById('fileInput');
        fileInput.setAttribute('multiple', ''); // Activar selección múltiple
        fileInput.addEventListener('change', handleFiles);

        async function handleFiles(e) {
            const files = Array.from(e.target.files);
            if (files.length === 0) return;

            alert(`Se han detectado ${files.length} archivo(s). Unificando datos...`);

            let combinedData = [];
            let errors = 0;

            // Procesar todos los archivos en paralelo
            const promises = files.map(file => {
                return new Promise((resolve) => {
                    const reader = new FileReader();

                    reader.onload = function (evt) {
                        try {
                            const text = evt.target.result;
                            let json = [];
                            // Detección PIPE/CSV o Excel
                            if (file.name.toLowerCase().endsWith('.csv') || text.indexOf('|') > -1) {
                                json = parseSpecificCSV(text);
                            } else {
                                const workbook = XLSX.read(text, { type: 'binary' });
                                json = XLSX.utils.sheet_to_json(workbook.Sheets[workbook.SheetNames[0]]);
                            }
                            resolve(json);
                        } catch (err) {
                            console.error("Error leyendo archivo:", file.name, err);
                            errors++;
                            resolve([]);
                        }
                    };

                    if (file.name.toLowerCase().endsWith('.csv')) {
                        reader.readAsText(file, 'UTF-8');
                    } else {
                        reader.readAsBinaryString(file);
                    }
                });
            });

            const results = await Promise.all(promises);
            results.forEach(res => { combinedData = combinedData.concat(res); });

            if (combinedData.length === 0) {
                alert("No se pudieron extraer datos de los archivos seleccionados.");
                return;
            }

            let msg = `¡Carga Exitosa!\nTotal registros: ${combinedData.length}`;
            if (errors > 0) msg += `\n(Hubo error en ${errors} archivos)`;
            alert(msg);

            processData(combinedData);
        }

        // --- HELPER PARA COLORES DINÁMICOS ---
        function getUESTheme(name) {
            // Colores de marca fijos
            const hardcoded = {
                'HOTELES': { bg: '#E3F2FD', text: '#0056A4', icon: 'fa-hotel' },
                'PISCILAGO': { bg: '#E8F5E9', text: '#2E7D32', icon: 'fa-water' },
                'RYD': { bg: '#FFF3E0', text: '#EF6C00', icon: 'fa-futbol' },
                'RECREACION': { bg: '#FFF3E0', text: '#EF6C00', icon: 'fa-futbol' }
            };
            if (hardcoded[name]) return hardcoded[name];

            // Generador de color pastel basado en el nombre (Hash)
            let hash = 0;
            for (let i = 0; i < name.length; i++) hash = name.charCodeAt(i) + ((hash << 5) - hash);

            const h = Math.abs(hash % 360);
            const bg = `hsl(${h}, 70%, 90%)`;   // Fondo suave
            const text = `hsl(${h}, 80%, 30%)`; // Texto oscuro contraste

            return { bg: bg, text: text, icon: 'fa-layer-group' };
        }

        // PARSER MANUAL MUY SIMPLE PARA "PIPE" (|)
        function parseSpecificCSV(text) {
            // Dividir por saltos de línea
            const lines = text.split(/\r\n|\n|\r/).filter(line => line.trim().length > 0);
            if (lines.length < 2) return [];

            // Helper para arreglar codificación (Mojibake: UTF-8 leído como ANSI y guardado)
            // Intenta revertir caracteres extraños como 'ÃƒÂ' -> 'Á'
            const fixEncoding = (str) => {
                try {
                    return decodeURIComponent(escape(str));
                } catch (e) {
                    return str; // Si falla, devuelve original
                }
            };

            // Helper para limpiar comillas (una o muchas)
            const clean = (str) => {
                if (!str) return '';
                let s = str.trim().replace(/^"+|"+$/g, '');
                return fixEncoding(s); // Aplicar corrección de tildes
            };

            // Detectar cabeceras en línea 1 (limpiando agresivamente)
            // El archivo real tiene cosas como: "FECHA_CORTE|""ANIO""...
            const headers = lines[0].split('|').map(h => clean(h));

            console.log("Cabeceras LIMPIAS:", headers);

            const result = [];

            for (let i = 1; i < lines.length; i++) {
                const rowStr = lines[i];
                if (!rowStr) continue;

                const parts = rowStr.split('|');

                let obj = {};
                for (let j = 0; j < headers.length; j++) {
                    let val = parts[j] ? parts[j] : '';
                    val = clean(val);
                    obj[headers[j]] = val;
                }

                if (Object.keys(obj).length > 0) {
                    result.push(obj);
                }
            }
            return result;
        }

        function processData(data) {
            // Log para debug
            console.log("Primeros 3 registros crudos:", data.slice(0, 3));

            // Mapeo seguro de columnas
            // Mapeo seguro de columnas con SINÓNIMOS
            rawData = data.map(row => {
                // Helper: busca valor probando varias llaves posibles
                const getVal = (possibleKeys) => {
                    if (!Array.isArray(possibleKeys)) possibleKeys = [possibleKeys];

                    const foundKey = Object.keys(row).find(k =>
                        possibleKeys.some(pk => k.trim().toUpperCase() === pk.toUpperCase())
                    );
                    return row[foundKey];
                };

                return {
                    id: getVal(['ID_EMPRESA', 'NIT', 'CODIGO', 'ID']),
                    empresa: getVal(['RAZON_SOCIAL', 'EMPRESA', 'NOMBRE', 'CLIENTE']),
                    ues: getVal(['UES', 'UNIDAD', 'NEGOCIO', 'AREA']) ? getVal(['UES', 'UNIDAD', 'NEGOCIO', 'AREA']).toUpperCase() : 'OTROS',
                    sede: getVal(['SEDE', 'LUGAR', 'UBICACION', 'SITIO']) || 'Desconocida',
                    anio: getVal(['ANIO', 'AÑO', 'YEAR']),
                    mes: getVal(['MES', 'MONTH']),
                    usos: parseFloat(getVal(['USOS', 'CANTIDAD', 'CONSUMOS', 'QTY']) || 0),
                    ventas: parseFloat(getVal(['VENTAS', 'VALOR', 'MONTO', 'TOTAL', 'PRECIO']) || 0),
                    personas: parseFloat(getVal(['CANT_PERSONAS_UNICAS', 'PERSONAS', 'USUARIOS', 'VISITANTES']) || 0)
                };
            }).filter(r => r.empresa && (r.ventas > 0 || r.usos > 0)); // Filtro: debe tener empresa y algo de actividad

            console.log("Datos procesados válidos:", rawData.length);

            if (rawData.length === 0) {
                alert("ALERTA: Se leyeron filas pero ninguna tenía 'ID_EMPRESA' o 'RAZON_SOCIAL' válido.\nRevise los nombres de columnas.");
                return;
            }

            // Empresas únicas
            const companiesMap = {};
            rawData.forEach(r => { companiesMap[r.id] = r.empresa; });
            companies = Object.entries(companiesMap).map(([id, name]) => ({ id, name }));
            companies.sort((a, b) => a.name.localeCompare(b.name));

            initApp();
        }

        /* =========================================
           2. INICIALIZACIÓN DE UI
           ========================================= */
        function initApp() {
            document.getElementById('splash').style.display = 'none';
            document.getElementById('dashboard').classList.add('active');

            const select = document.getElementById('companySelect');
            select.innerHTML = '<option value="ALL">-- Ver Todas --</option>';
            companies.forEach(c => {
                const opt = document.createElement('option');
                opt.value = c.id;
                opt.textContent = c.name;
                select.appendChild(opt);
            });
            select.disabled = false;

            if (companies.length > 0) select.value = companies[0].id;
            renderDashboard(select.value);

            select.addEventListener('change', (e) => {
                renderDashboard(e.target.value);
            });
        }

        /* =========================================
           3. RENDERIZADO DE GRÁFICOS Y KPIs
           ========================================= */
        function renderDashboard(companyId) {
            // Filtrar datos
            let filteredData = rawData;
            if (companyId !== 'ALL') {
                filteredData = rawData.filter(d => d.id === companyId);
            }

            // --- A. CALCULAR MÉTRICAS GLOBALES ---
            const totalVentas = filteredData.reduce((acc, curr) => acc + curr.ventas, 0);
            const totalUsos = filteredData.reduce((acc, curr) => acc + curr.usos, 0);
            const totalPersonas = filteredData.reduce((acc, curr) => acc + curr.personas, 0);

            // --- B. AGRUPACIÓN POR UES ---
            const uesStats = {};

            filteredData.forEach(d => {
                if (!uesStats[d.ues]) {
                    uesStats[d.ues] = {
                        ventas: 0,
                        usos: 0,
                        personas: 0,
                        sedes: new Set(),
                        sedesDetail: {} // Nuevo: Detalle por sede
                    };
                }
                uesStats[d.ues].ventas += d.ventas;
                uesStats[d.ues].usos += d.usos;
                uesStats[d.ues].personas += d.personas;
                uesStats[d.ues].sedes.add(d.sede);

                // Agregar al detalle
                if (!uesStats[d.ues].sedesDetail[d.sede]) {
                    uesStats[d.ues].sedesDetail[d.sede] = { ventas: 0, usos: 0 };
                }
                uesStats[d.ues].sedesDetail[d.sede].ventas += d.ventas;
                uesStats[d.ues].sedesDetail[d.sede].usos += d.usos;
            });

            // Guardar en global para el modal
            currentUESStats = uesStats;

            // Ordenar UES por Ventas Desc
            const sortedUES = Object.entries(uesStats).sort((a, b) => b[1].ventas - a[1].ventas);

            // --- C. AGRUPACIÓN TEMPORAL (GLOBAL) ---
            const timeData = {};
            filteredData.forEach(d => {
                const month = d.mes.toString().padStart(2, '0');
                const key = `${d.anio}-${month}`;
                timeData[key] = (timeData[key] || 0) + d.ventas;
            });
            const sortedTimeKeys = Object.keys(timeData).sort();


            // --- D. ACTUALIZAR DOM ---

            // KPIs Sidebar
            document.getElementById('kpi-ventas').textContent = formatCurrency(totalVentas);
            document.getElementById('kpi-usos').textContent = totalUsos.toLocaleString();
            document.getElementById('kpi-personas').textContent = totalPersonas.toLocaleString();

            // GENERAR SECCIONES UES (TARJETAS)
            const uesContainer = document.getElementById('ues-container');
            uesContainer.innerHTML = '';

            sortedUES.forEach(([name, stats]) => {
                // Usar sistema de colores dinámico
                const theme = getUESTheme(name);

                const cardHTML = `
                <div class="chart-card mini">
                    <div class="chart-header">
                        <div class="chart-title" style="color:${theme.text}; display:flex; gap:10px; align-items:center;">
                            <div class="icon-box" style="background:${theme.bg}; color:${theme.text}; width:30px; height:30px; font-size:1rem;">
                                <i class="fa-solid ${theme.icon}"></i>
                            </div>
                            ${name}
                        </div>
                    </div>
                    <div class="ues-card-content">
                        <div class="ues-metric">
                            <span>Ventas</span>
                            <span class="ues-value" style="color:${theme.text}">${formatCurrency(stats.ventas)}</span>
                        </div>
                         <div class="ues-metric">
                            <span>Usos</span>
                            <span class="ues-value" style="color:#666; font-size:1rem;">${stats.usos.toLocaleString()}</span>
                        </div>
                        <div class="ues-metric clickable-metric" onclick="openDetailModal('${name}')" title="Clic para ver detalle por Sedes">
                            <span>Sedes Activas <i class="fa-solid fa-magnifying-glass-plus" style="font-size:0.8em; margin-left:5px;"></i></span>
                            <span class="ues-value" style="color:${theme.text}; font-size:1rem;">${stats.sedes.size}</span>
                        </div>
                    </div>
                </div>
                `;
                uesContainer.innerHTML += cardHTML;
            });

            // --- E. RENDERIZAR CHARTS ---
            updateCharts(sortedUES, sortedTimeKeys, timeData);
        }

        function updateCharts(sortedUES, timeKeys, timeDataObj) {
            // 1. UES PIE CHART
            const ctxUes = document.getElementById('chart-ues').getContext('2d');
            if (charts.ues) charts.ues.destroy();

            const labels = sortedUES.map(x => x[0]);
            const dataValues = sortedUES.map(x => x[1].ventas);

            // Colores dinámicos para el gráfico
            const bgColors = labels.map(l => getUESTheme(l).text);

            charts.ues = new Chart(ctxUes, {
                type: 'doughnut',
                data: {
                    labels: labels,
                    datasets: [{
                        data: dataValues,
                        backgroundColor: bgColors,
                        borderWidth: 0
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { position: 'bottom' }
                    }
                }
            });

            // 2. TIME CHART
            const ctxTime = document.getElementById('chart-mensual').getContext('2d');
            if (charts.time) charts.time.destroy();

            charts.time = new Chart(ctxTime, {
                type: 'line',
                data: {
                    labels: timeKeys,
                    datasets: [{
                        label: 'Ventas Totales ($)',
                        data: timeKeys.map(k => timeDataObj[k]),
                        borderColor: '#F5B400',
                        backgroundColor: 'rgba(245, 180, 0, 0.1)',
                        fill: true,
                        tension: 0.3,
                        pointRadius: 3
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { display: false },
                        tooltip: { callbacks: { label: (c) => formatCurrency(c.raw) } }
                    },
                    scales: {
                        y: { ticks: { callback: (v) => '$' + v / 1000 + 'k' } }
                    }
                }
            });
        }

        // FUNCIONES DEL MODAL
        function openDetailModal(uesName) {
            if (!currentUESStats[uesName]) return;

            const stats = currentUESStats[uesName];
            const details = stats.sedesDetail;

            document.getElementById('modalTitle').textContent = "Detalle: " + uesName;

            const tbody = document.getElementById('modalBody');
            tbody.innerHTML = '';

            // Convertir a array y ordenar por ventas
            const rows = Object.entries(details).sort((a, b) => b[1].ventas - a[1].ventas);

            rows.forEach(([sedeName, metrics]) => {
                const tr = document.createElement('tr');
                tr.innerHTML = `
                    <td>${sedeName}</td>
                    <td style="text-align:right;">${metrics.usos.toLocaleString()}</td>
                    <td style="text-align:right; font-weight:bold;">${formatCurrency(metrics.ventas)}</td>
                `;
                tbody.appendChild(tr);
            });

            document.getElementById('detailModal').classList.add('active');
        }

        function closeModal() {
            document.getElementById('detailModal').classList.remove('active');
        }

        // Cerrar al hacer click fuera
        document.getElementById('detailModal').addEventListener('click', function (e) {
            if (e.target === this) closeModal();
        });

        function formatCurrency(val) {
            return new Intl.NumberFormat('es-CO', { style: 'currency', currency: 'COP', maximumFractionDigits: 0 }).format(val);
        }

    </script>
</body>

</html>