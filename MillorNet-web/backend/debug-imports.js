console.log("=== DEBUG DE IMPORTS ===\n");

console.log("1. Intentando cargar auth.controller...");
try {
  const controller = require('./src/controllers/auth.controller');
  console.log("✅ auth.controller cargado");
  console.log("   - Tipo de register:", typeof controller.register);
  console.log("   - Tipo de login:", typeof controller.login);
  console.log("   - Keys del objeto:", Object.keys(controller));
} catch (error) {
  console.log("❌ Error:", error.message);
}

console.log("\n2. Intentando cargar auth.routes...");
try {
  const routes = require('./src/routes/auth.routes');
  console.log("✅ auth.routes cargado");
} catch (error) {
  console.log("❌ Error:", error.message);
}

console.log("\n3. Verificando estructura de auth.controller.js...");
const fs = require('fs');
const controllerContent = fs.readFileSync('./src/controllers/auth.controller.js', 'utf8');
const lines = controllerContent.split('\n');

// Buscar la exportación
let exportFound = false;
for (let i = 0; i < lines.length; i++) {
  if (lines[i].includes('module.exports') || lines[i].includes('exports.')) {
    console.log(`   Línea ${i+1}: ${lines[i]}`);
    exportFound = true;
  }
}

if (!exportFound) {
  console.log("   ❌ No se encontró exportación en auth.controller.js");
}
