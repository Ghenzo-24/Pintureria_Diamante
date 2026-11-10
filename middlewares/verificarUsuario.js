// MIDDLEWARE: ¿quien compra?
// Va entre la ruta y el controller. Si no hay token valido, corta con 401.
// Si todo esta bien, deja el usuario en req.usuario y sigue.
const supabase = require('../config/supabaseClient');

async function verificarUsuario(req, res, next) {
 const header = req.headers.authorization || '';
 const token = header.replace('Bearer ', '');
 if (!token) return res.status(401).send('Tenes que iniciar sesion');
 let data;
 let error;
 try {
  ({ data, error } = await supabase.auth.getUser(token));
 } catch (err) {
  console.error('Error al verificar la sesion:', err);
  return res.status(503).send('No se pudo verificar la sesion');
 }
 if (error || !data.user) return res.status(401).send('Sesion invalida');
 req.usuario = data.user; // desde acá, el controller sabe quién compra
 next();
}


module.exports = verificarUsuario;
