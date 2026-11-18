
export default {
  async fetch(request, env) {
    const cors = {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "GET, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type"
    };

    const json = (data, status = 200) =>
      new Response(JSON.stringify(data), {
        status,
        headers: {
          ...cors,
          "Content-Type": "application/json; charset=utf-8"
        }
      });

    if (request.method === "OPTIONS") {
      return new Response(null, { status: 204, headers: cors });
    }

    if (request.method !== "GET") {
      return json({ error: "Méthode non autorisée" }, 405);
    }

    if (!env.FOOTBALL_API_KEY) {
      return json({ error: "Secret FOOTBALL_API_KEY absent" }, 500);
    }

    const url = new URL(request.url);
    const path = url.pathname;

    async function apiFetch(endpoint) {
      const response = await fetch(
        "https://v3.football.api-sports.io" + endpoint,
        {
          headers: { "x-apisports-key": env.FOOTBALL_API_KEY }
        }
      );

      const data = await response.json();

      if (!response.ok || (data.errors && Object.keys(data.errors).length)) {
        throw new Error(JSON.stringify(data.errors || data));
      }

      return data;
    }

    try {
      if (path === "/fixtures/live") {
        return json(await apiFetch("/fixtures?live=all"));
      }

      if (path === "/fixtures/upcoming") {
        const dates = [];

        for (let i = 0; i < 7; i++) {
          const date = new Date();
          date.setUTCDate(date.getUTCDate() + i);
          dates.push(date.toISOString().slice(0, 10));
        }

        const results = await Promise.all(
          dates.map(date =>
            apiFetch("/fixtures?date=" + date)
          )
        );

        const matches = results
          .flatMap(result => result.response || [])
          .filter(match => {
            const status = match.fixture?.status?.short;
            return status === "NS" || status === "TBD";
          })
          .sort((a, b) =>
            new Date(a.fixture.date) - new Date(b.fixture.date)
          );

        return json({
          period: "7 prochains jours",
          results: matches.length,
          response: matches
        });
      }

      if (path === "/fixtures") {
        const date = url.searchParams.get("date");

        if (!date || !/^\d{4}-\d{2}-\d{2}$/.test(date)) {
          return json({ error: "Date invalide : YYYY-MM-DD" }, 400);
        }

        return json(await apiFetch("/fixtures?date=" + date));
      }

      if (path === "/fixtures/statistics") {
        const fixture = url.searchParams.get("fixture");

        if (!fixture || !/^\d+$/.test(fixture)) {
          return json({ error: "Identifiant du match invalide" }, 400);
        }

        return json(
          await apiFetch("/fixtures/statistics?fixture=" + fixture)
        );
      }

      return json({
        error: "Route inconnue",
        routes: [
          "/fixtures/live",
          "/fixtures/upcoming",
          "/fixtures?date=2026-11-18",
          "/fixtures/statistics?fixture=8214"
        ]
      }, 404);

    } catch (error) {
      return json({
        error: "Erreur API-Football",
        details: error.message
      }, 502);
    }
  }
};
