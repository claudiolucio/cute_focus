defmodule CuteFocusWeb.RoomLive do
  use CuteFocusWeb, :live_view

  alias CuteFocus.{Agents, Focus}

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "iza's room",
       room: Focus.room(socket.assigns.current_scope),
       companion_note: nil,
       generating_note?: false
     )}
  end

  @impl true
  def handle_event("ask_companion", _params, socket) do
    scope = socket.assigns.current_scope
    room = socket.assigns.room

    {:noreply,
     socket
     |> assign(generating_note?: true)
     |> start_async(:companion_note, fn -> Agents.companion_note(scope, room) end)}
  end

  def handle_event("reset_progress", _params, socket) do
    {deleted_sessions, _} = Focus.reset_progress(socket.assigns.current_scope)

    {:noreply,
     socket
     |> assign(room: Focus.room(socket.assigns.current_scope), companion_note: nil)
     |> put_flash(
       :info,
       "#{deleted_sessions} focus sessions were reset. Your room is ready for a fresh start."
     )}
  end

  @impl true
  def handle_async(:companion_note, {:ok, {:ok, note}}, socket) do
    {:noreply, assign(socket, companion_note: note, generating_note?: false)}
  end

  def handle_async(:companion_note, _result, socket) do
    {:noreply,
     socket
     |> assign(generating_note?: false)
     |> put_flash(:error, "Liro is napping. Try again in a moment.")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="min-h-screen bg-[#f7f2ea] px-4 py-10 text-[#29241f] sm:px-8 sm:py-16">
        <section class="mx-auto max-w-4xl">
          <div class="flex flex-wrap items-start justify-between gap-4">
            <div>
              <p class="text-xs font-black uppercase tracking-[0.2em] text-[#ca6d2e]">
                iza's little place
              </p><h1 class="mt-2 text-4xl font-black tracking-[-0.07em] sm:text-5xl">my room</h1>
            </div>
            <.link
              navigate={~p"/"}
              class="rounded-full border border-[#d9cfc2] bg-white px-4 py-2 text-xs font-black tracking-[0.1em] transition hover:border-[#e48740] hover:text-[#c96528]"
            >BACK TO FOCUS</.link>
          </div>

          <div
            id="room-scene"
            data-room-mood={@room.mood}
            data-room-level={@room.level}
            class="room-scene mt-8 overflow-hidden border-[6px] border-[#292622] shadow-[10px_10px_0_#c9ad8d]"
          >
            <img
              class="room-asset room-background"
              src={room_asset(background_sprite(@room.mood))}
              alt={scene_alt(@room.mood)}
            />
            <img
              :if={@room.unlocked.plant}
              class="room-asset room-plant-sprite"
              src={room_asset("plant.png")}
              alt="Unlocked desk plant"
            />
            <img
              :if={@room.unlocked.books}
              class="room-asset room-books-sprite"
              src={room_asset("books.png")}
              alt="Unlocked book stack"
            />
            <img
              :if={@room.unlocked.poster}
              class="room-asset room-poster-sprite"
              src={room_asset("poster.png")}
              alt="Unlocked room poster"
            />
            <img
              :if={@room.unlocked.cat}
              class="room-asset room-companion-sprite"
              src={room_asset("companion_idle.png")}
              alt="Liro, the pocket companion"
            />
            <div id="room-level" class="room-level">LV {@room.level}</div>
            <div class="room-status">
              <span class="room-status-dot"></span>{status_text(@room.mood)}
            </div>
          </div>

          <div class="mt-10 grid gap-4 md:grid-cols-[1.1fr_0.9fr]">
            <div class="rounded-[1.75rem] border border-[#e0d6ca] bg-white p-6">
              <p class="text-xs font-black uppercase tracking-[0.15em] text-[#a09588]">
                your room level
              </p><p id="room-session-count" class="mt-3 text-4xl font-black tracking-[-0.07em]">
                {@room.completed_sessions} <span class="text-lg text-[#857c72]">sessions</span>
              </p><p class="mt-3 text-sm leading-6 text-[#756d64]">
                Every finished session makes this little space more yours. You have focused for {@room.total_minutes} minutes so far.
              </p><button
                id="room-reset"
                phx-click="reset_progress"
                data-confirm="Reset all focus sessions and room unlocks?"
                class="mt-5 text-xs font-black uppercase tracking-[0.12em] text-[#b75043] transition hover:text-[#81382f]"
              >reset my progress</button>
            </div>
            <div class="rounded-[1.75rem] bg-[#282522] p-6 text-[#f8f1e6]">
              <p class="text-xs font-black uppercase tracking-[0.15em] text-[#f09a4b]">
                next cozy thing
              </p><p id="room-next-unlock" class="mt-3 text-2xl font-black">
                {next_unlock(@room.completed_sessions)}
              </p><p class="mt-3 text-sm leading-6 text-[#bbb2a8]">
                {unlock_hint(@room.completed_sessions)}
              </p>
            </div>
          </div>
          <section
            id="companion-note"
            class="mt-4 border-[3px] border-[#292622] bg-[#f9e8a8] p-5 shadow-[6px_6px_0_#d49d62]"
          >
            <div class="flex flex-wrap items-center justify-between gap-4">
              <div>
                <p class="font-mono text-[10px] font-black uppercase tracking-[0.18em] text-[#925537]">
                  liro's pixel note
                </p>
                <p class="mt-2 text-sm font-bold leading-6 text-[#4a342c]">
                  {@companion_note || "Ask Liro for a little boost based on your room."}
                </p>
              </div>
              <button
                id="ask-companion"
                phx-click="ask_companion"
                disabled={@generating_note?}
                class="border-[3px] border-[#292622] bg-[#f17b55] px-4 py-3 font-mono text-xs font-black uppercase tracking-[0.08em] text-[#fff8dc] shadow-[4px_4px_0_#292622] transition hover:-translate-y-0.5 disabled:cursor-wait disabled:opacity-60"
              >{if @generating_note?, do: "Liro is thinking", else: "Ask Liro"}</button>
            </div>
          </section>
        </section>
      </div>
    </Layouts.app>
    """
  end

  defp status_text(:studying), do: "studying right now"
  defp status_text(:celebrating), do: "proud of today's work"
  defp status_text(:resting), do: "waiting for your first focus session"

  defp room_asset(filename), do: ~p"/images/room/#{filename}"
  defp background_sprite(:studying), do: "room_background_night.png"
  defp background_sprite(_mood), do: "room_background_day.png"
  defp scene_alt(:studying), do: "Iza's pixel study room at night"
  defp scene_alt(:celebrating), do: "Iza's warm pixel study room"
  defp scene_alt(:resting), do: "Iza's warm pixel study room"

  defp next_unlock(count) when count < 1, do: "a tiny desk plant"
  defp next_unlock(count) when count < 3, do: "a pocket companion"
  defp next_unlock(count) when count < 5, do: "a stack of favorite books"
  defp next_unlock(count) when count < 8, do: "a motivational poster"
  defp next_unlock(_count), do: "the room is glowing"

  defp unlock_hint(count) when count < 1, do: "Complete 1 focus session to bring in some green."
  defp unlock_hint(count) when count < 3, do: "Complete 3 sessions to invite a tiny study buddy."
  defp unlock_hint(count) when count < 5, do: "Complete 5 sessions to fill the bookshelf."
  defp unlock_hint(count) when count < 8, do: "Complete 8 sessions to hang a little reminder."
  defp unlock_hint(_count), do: "You made this room entirely yours."
end
