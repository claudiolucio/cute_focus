defmodule CuteFocusWeb.StatsLive do
  use CuteFocusWeb, :live_view

  alias CuteFocus.Focus

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(page_title: "focus stats")
     |> assign(:stats, Focus.stats(socket.assigns.current_scope))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="min-h-screen bg-[#faf8f4] px-4 py-10 text-[#24221f] sm:px-8 sm:py-16">
        <section class="mx-auto max-w-3xl">
          <.link
            navigate={~p"/"}
            class="text-xs font-black tracking-[0.18em] text-[#df7b31] transition hover:text-[#ae5720]"
          >&larr; BACK TO FOCUS</.link>
          <div class="mt-5 flex flex-wrap items-end justify-between gap-4">
            <div>
              <p class="text-xs font-bold uppercase tracking-[0.2em] text-[#df7b31]">
                iza's quiet progress
              </p><h1 class="mt-2 text-4xl font-black tracking-[-0.07em] sm:text-5xl">focus stats</h1>
            </div><p class="rounded-full bg-[#f1dfce] px-4 py-2 text-xs font-bold text-[#85491d]">
              keep going gently
            </p>
          </div>
          <div id="stats-summary" class="mt-8 grid grid-cols-2 gap-3 sm:grid-cols-4">
            <.stat_card label="today" value={"#{@stats.today_minutes}m"} /><.stat_card
              label="all focus"
              value={"#{@stats.total_minutes}m"}
            /><.stat_card label="sessions" value={@stats.session_count} /><.stat_card
              label="favorite"
              value={@stats.favorite_activity}
            />
          </div>
          <div class="mt-8 rounded-[2rem] border border-[#e3dcd2] bg-white p-5 shadow-sm sm:p-7">
            <div class="flex items-center justify-between">
              <h2 class="text-lg font-black">recent sessions</h2><span class="text-xs text-[#8c847a]">saved to your space</span>
            </div><div id="recent-sessions" class="mt-4 divide-y divide-[#eee9e2]">
              <p
                :if={@stats.sessions == []}
                id="empty-sessions"
                class="py-8 text-center text-sm text-[#8c847a]"
              >
                Your completed focus sessions will appear here.
              </p><div
                :for={session <- @stats.sessions}
                id={"session-#{session.id}"}
                class="flex items-center justify-between py-4"
              >
                <div>
                  <p class="font-bold">{session.activity.name}</p><p class="mt-1 text-xs text-[#8c847a]">
                    {Calendar.strftime(session.started_at, "%b %-d, %Y")}
                  </p>
                </div><span class="rounded-full bg-[#fff0df] px-3 py-1 text-xs font-black text-[#bd672a]">{div(
                  session.duration_seconds,
                  60
                )} min</span>
              </div>
            </div>
          </div>
        </section>
      </div>
    </Layouts.app>
    """
  end

  attr :label, :string, required: true
  attr :value, :any, required: true

  defp stat_card(assigns) do
    ~H"""
    <div class="min-h-28 rounded-3xl border border-[#e3dcd2] bg-white p-4 shadow-sm">
      <p class="text-[10px] font-black uppercase tracking-[0.14em] text-[#9a9188]">{@label}</p><p class="mt-3 break-words text-2xl font-black tracking-[-0.06em] text-[#322d28]">
        {@value}
      </p>
    </div>
    """
  end
end
