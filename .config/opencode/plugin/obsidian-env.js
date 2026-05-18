export default async () => ({
  config: (cfg) => {
    const token = process.env.OBSIDIAN_API_KEY
    const obsidian = cfg.mcp?.obsidian

    if (!token || !obsidian || obsidian.type !== "remote") return

    obsidian.headers = {
      ...(obsidian.headers ?? {}),
      Authorization: `Bearer ${token}`,
    }
    obsidian.oauth = false
  },
})
