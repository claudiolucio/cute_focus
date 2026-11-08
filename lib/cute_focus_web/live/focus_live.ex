defmodule CuteFocusWeb.FocusLive do
  use CuteFocusWeb, :live_view

  alias CuteFocus.Focus

  @focus_seconds 25 * 60

  @impl true
  def mount(_params, _session, socket) do
    activities = Focus.activities()
    selected_activity = List.first(activities)

    socket =
      socket
      |> stream_configure(:activities, dom_id: &"activity-#{&1.id}")
      |> stream(:activities, activities)
      |> assign(
        page_title: "liro study space for iza",
        selected_activity: selected_activity,
        activity_by_id: Map.new(activities, &{&1.id, &1}),
        remaining_seconds: @focus_seconds,
        running?: false,
        session: nil
      )

    if connected?(socket), do: :timer.send_interval(1_000, :tick)

    {:ok, socket}
  end

  @impl true
  def handle_event("select_activity", %{"id" => id}, socket) do
    case Integer.parse(id) do
      {activity_id, ""} ->
        case socket.assigns.activity_by_id[activity_id] do
          nil ->
            {:noreply, socket}

          activity ->
            {:noreply,
             socket
             |> assign(selected_activity: activity)
             |> stream_insert(:activities, socket.assigns.selected_activity)
             |> stream_insert(:activities, activity)}
        end

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("start", _params, socket) do
    case Focus.start_session(socket.assigns.current_scope, socket.assigns.selected_activity) do
      {:ok, session} ->
        {:noreply, assign(socket, running?: true, session: session)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Your session could not start. Try again.")}
    end
  end

  def handle_event("pause", _params, socket), do: {:noreply, save_and_stop(socket)}

  def handle_event("reset", _params, socket) do
    {:noreply, socket |> save_and_stop() |> assign(remaining_seconds: @focus_seconds)}
  end

  @impl true
  def handle_info(:tick, %{assigns: %{running?: true, remaining_seconds: 1}} = socket) do
    {:noreply,
     socket
     |> save_and_stop()
     |> assign(remaining_seconds: 0)
     |> push_event("focus_complete", %{})
     |> put_flash(:info, "A lovely focus session, complete.")}
  end

  def handle_info(:tick, %{assigns: %{running?: true}} = socket) do
    {:noreply, update(socket, :remaining_seconds, &(&1 - 1))}
  end

  def handle_info(:tick, socket), do: {:noreply, socket}

  defp save_and_stop(%{assigns: %{session: nil}} = socket), do: assign(socket, running?: false)

  defp save_and_stop(socket) do
    elapsed_seconds = @focus_seconds - socket.assigns.remaining_seconds
    _ = Focus.finish_session(socket.assigns.session, elapsed_seconds)
    assign(socket, running?: false, session: nil)
  end

  defp timer_text(seconds) do
    "#{String.pad_leading(Integer.to_string(div(seconds, 60)), 2, "0")}:#{String.pad_leading(Integer.to_string(rem(seconds, 60)), 2, "0")}:00"
  end

  defp progress_width(seconds), do: round((@focus_seconds - seconds) / @focus_seconds * 100)

  defp pixel_sprite(assigns) do
    ~H"""
    <span class="pixel-sprite" data-sprite={@sprite} aria-hidden="true">
      <i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i>
    </span>
    """
  end

  @impl true
  def render(assigns) do
    assigns =
      assigns
      |> assign(:timer_text, timer_text(assigns.remaining_seconds))
      |> assign(:progress_width, progress_width(assigns.remaining_seconds))

    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div id="focus-audio" phx-hook="FocusAudio" phx-update="ignore"></div>
      <div class="min-h-screen bg-[#faf8f4] px-4 py-10 font-[ui-rounded,system-ui,sans-serif] text-[#24221f] sm:px-8 sm:py-16">
        <section class="mx-auto flex max-w-5xl flex-col items-center gap-8">
          <div class="text-center">
            <p class="mb-3 text-xs font-bold uppercase tracking-[0.25em] text-[#df7b31]">
              a little corner to focus
            </p>
            <h1 class="text-3xl font-black tracking-[-0.07em] sm:text-5xl">
              liro study space for iza
            </h1>
            <p class="mt-3 text-sm text-[#74706a]">one small task at a time, you have this.</p>
          </div>

          <div class="w-full max-w-[430px] rounded-[2rem] border-[6px] border-[#272522] bg-[#121212] p-4 shadow-[0_18px_0_#d6d0c7,0_28px_50px_rgba(41,35,28,0.2)] sm:p-5">
            <div class="flex items-center justify-between text-[10px] font-bold text-[#aaa59d]">
              <span>IZA'S FOCUS</span><span class="rounded-full bg-[#252525] px-2 py-1 text-[#f09a4b]">TODAY</span>
            </div>
            <div class="mt-6 flex items-end justify-between">
              <div>
                <p class="text-xs text-[#8e8980]">selected mode</p><p
                  id="selected-activity"
                  class="mt-1 text-lg font-bold text-[#f5f1e9]"
                >
                  {@selected_activity.name}
                </p>
              </div><.pixel_sprite sprite={@selected_activity.sprite_key} />
            </div>
            <div class="mt-5">
              <div
                id="focus-timer"
                class="font-mono text-5xl font-bold tracking-[-0.09em] text-[#fcfaf5] sm:text-6xl"
              >
                {@timer_text}
              </div><div class="mt-4 h-1.5 overflow-hidden rounded-full bg-[#34312e]">
                <div
                  class="h-full rounded-full bg-[#f18a36] transition-[width] duration-500"
                  style={"width: #{@progress_width}%"}
                >
                </div>
              </div>
            </div>
            <div class="mt-5 grid grid-cols-3 gap-2">
              <button
                id="start-focus"
                phx-click="start"
                disabled={@running?}
                class="rounded-xl bg-[#f08b37] px-3 py-3 text-xs font-black text-[#201812] transition hover:bg-[#ff9f50] disabled:cursor-not-allowed disabled:opacity-50"
              >START</button><button
                id="pause-focus"
                phx-click="pause"
                disabled={!@running?}
                class="rounded-xl bg-[#292929] px-3 py-3 text-xs font-black text-[#f6f2eb] transition hover:bg-[#373737] disabled:cursor-not-allowed disabled:opacity-50"
              >PAUSE</button><button
                id="reset-focus"
                phx-click="reset"
                class="rounded-xl bg-[#292929] px-3 py-3 text-xs font-black text-[#c8c2b8] transition hover:bg-[#373737]"
              >RESET</button>
            </div>
            <div class="mt-7 border-t border-[#2c2a27] pt-5">
              <div class="mb-3 flex items-center justify-between">
                <p class="text-xs font-bold text-[#eee9df]">What are we doing?</p><p class="text-[10px] text-[#77716a]">
                  pick a buddy
                </p>
              </div><div id="activities" phx-update="stream" class="grid grid-cols-3 gap-2">
                <button
                  :for={{dom_id, activity} <- @streams.activities}
                  id={dom_id}
                  phx-click="select_activity"
                  phx-value-id={activity.id}
                  data-activity={activity.name}
                  aria-pressed={@selected_activity.id == activity.id}
                  class={[
                    "group relative flex min-h-24 flex-col items-center justify-center rounded-2xl border px-2 py-3 transition hover:-translate-y-0.5",
                    if(@selected_activity.id == activity.id,
                      do:
                        "scale-[1.03] border-[#f08b37] bg-[#30251e] shadow-[0_0_0_2px_rgba(240,139,55,0.2),inset_0_0_0_1px_#f08b37]",
                      else: "border-[#2e2c2a] bg-[#1e1e1e] hover:border-[#605a51]"
                    )
                  ]}
                ><span
                  :if={@selected_activity.id == activity.id}
                  class="absolute right-2 top-2 rounded-full bg-[#f08b37] px-1.5 py-0.5 text-[7px] font-black tracking-wider text-[#201812]"
                >ON</span><.pixel_sprite sprite={activity.sprite_key} /><span class="mt-2 text-[10px] font-bold text-[#d8d1c6]">{activity.name}</span></button>
              </div>
            </div>
            <div class="mt-6 flex items-center justify-around border-t border-[#2c2a27] pt-4 text-[#716c66]">
              <span class="text-[10px] font-bold tracking-widest text-[#f08b37]">FOCUS</span><.link
                id="stats-link"
                navigate={~p"/stats"}
                class="text-[10px] font-bold tracking-widest transition hover:text-[#f08b37]"
              >STATS</.link><.link
                id="room-link"
                navigate={~p"/room"}
                class="text-[10px] font-bold tracking-widest transition hover:text-[#f08b37]"
              >MY ROOM</.link>
            </div>
          </div>
          <p class="max-w-sm text-center text-xs leading-5 text-[#918a82]">
            A tiny focus display, designed to grow into a pixel companion for the desk.
          </p>
        </section>
      </div>
    </Layouts.app>
    """
  end
end
