import { useEffect, useState } from "react";
import api from "../api/axios";

export default function Dashboard() {
  const [projects, setProjects] = useState([]);
  const token = localStorage.getItem("token");

  useEffect(() => {
    api.get("/projects", {
      headers: { Authorization: `Bearer ${token}` }
    }).then(res => setProjects(res.data));
  }, []);

  return (
    <div>
      <h2>My Projects</h2>
      {projects.map(p => (
        <div key={p.id}>{p.name}</div>
      ))}
    </div>
  );
      }
