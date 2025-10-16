import express from "express";
import pkg from "pg";
const { Pool } = pkg;
import cors from "cors";
import multer from "multer";
import path from "path";

const app = express();
app.use(express.json());
app.use(cors());

// ✅ Хранилище для файлов
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, "uploads/"),
  filename: (req, file, cb) =>
    cb(null, Date.now() + path.extname(file.originalname)),
});

const upload = multer({ storage });

// ✅ Раздаём папку uploads как статику
app.use("/uploads", express.static("uploads"));

// ✅ Подключение к PostgreSQL
const pool = new Pool({
  user: "postgres",
  host: "localhost",
  database: "recipes_db",
  password: "19189",
  port: 5432,
});

pool.connect()
  .then(client => {
    console.log("✅ Connected to PostgreSQL!");
    client.release();
  })
  .catch(err => {
    console.error("❌ Failed to connect to PostgreSQL:", err.message);
  });

// Проверка API
app.get("/", (req, res) => {
  res.send("✅ API работает!");
});

// ✅ Добавление рецепта с фото, видео и аудио
app.post("/recipes", upload.fields([
  { name: "image", maxCount: 1 },
  { name: "video", maxCount: 1 },
  { name: "audio", maxCount: 1 }
]), async (req, res) => {
  const { title, description } = req.body;

  const baseUrl = `${req.protocol}://${req.headers.host}`;
  const imageUrl = req.files["image"]
    ? `${baseUrl}/uploads/${req.files["image"][0].filename}`
    : null;

  const videoUrl = req.files["video"]
    ? `${baseUrl}/uploads/${req.files["video"][0].filename}`
    : null;

  const audioUrl = req.files["audio"]
    ? `${baseUrl}/uploads/${req.files["audio"][0].filename}`
    : null;

  try {
    const result = await pool.query(
      "INSERT INTO recipes (title, description, image_url, video_url, audio_url, favorite) VALUES ($1, $2, $3, $4, $5, false) RETURNING *",
      [title, description, imageUrl, videoUrl, audioUrl]
    );
    res.json(result.rows[0]);
  } catch (err) {
    console.error("❌ Ошибка при добавлении рецепта:", err.message);
    res.status(500).json({ error: err.message });
  }
});

// ✅ Получение всех рецептов
app.get("/recipes", async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM recipes ORDER BY id DESC");
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ✅ Избранные рецепты
app.get("/favorites", async (req, res) => {
  try {
    const result = await pool.query(
      "SELECT * FROM recipes WHERE favorite = true ORDER BY id DESC"
    );
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ✅ Toggle избранного
app.patch("/recipes/:id/favorite", async (req, res) => {
  const { id } = req.params;
  const { favorite } = req.body;

  try {
    const result = await pool.query(
      "UPDATE recipes SET favorite = $1 WHERE id = $2 RETURNING *",
      [favorite, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Рецепт не найден" });
    }

    res.json(result.rows[0]);
  } catch (err) {
    console.error("❌ Ошибка toggleFavorite:", err.message);
    res.status(500).json({ error: err.message });
  }
});

// ✅ Удаление рецепта
app.delete("/recipes/:id", async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query("DELETE FROM recipes WHERE id = $1", [id]);
    res.json({ message: "Рецепт удалён" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

const PORT = 3000;
app.listen(PORT, "0.0.0.0", () =>
  console.log(`🚀 Server started on http://0.0.0.0:${PORT}`)
);
