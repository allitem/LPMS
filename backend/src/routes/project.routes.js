const router = require("express").Router();
const pool = require("../config/db");
const auth = require("../middleware/auth");

router.get("/", auth, async (req, res) => {
  const projects = await pool.query(
    "SELECT * FROM projects WHERE user_id=$1",
    [req.user.id]
  );
  res.json(projects.rows);
});

router.post("/", auth, async (req, res) => {
  const { name } = req.body;

  const project = await pool.query(
    "INSERT INTO projects (name,user_id) VALUES ($1,$2) RETURNING *",
    [name, req.user.id]
  );

  res.json(project.rows[0]);
});

module.exports = router;
