defmodule MissedUWeb.AppLive do
  use MissedUWeb, :live_view

  def render(assigns) do
    ~H"""
    <h1 class="text-4xl font-black">Welcome, <%= @profile.name %></h1>

    <div id="location-manager" phx-hook="LocationManager">
      <%= if is_nil(@position) do %>
        <p>We need your location to discover nearby traces</p>
        <.button phx-click={JS.dispatch("track-location")}>Grant Permission</.button>
      <% else %>
        <section>
          <p>
            <%= display_total_trace_count(@nearby_count) %> in this area.
            <.link
              navigate={~p"/traces/new?latitude=#{@position.latitude}&longitude=#{@position.longitude}"}
              class="underline">
              Leave a trace
            </.link>.
          </p>

          <.simple_form for={@key_form} phx-submit="unlock">
            <.input field={@key_form[:value]} label="Key"/>
            <:actions>
              <.button>Unlock Traces</.button>
            </:actions>
          </.simple_form>

          <%= if !is_nil(@unlocked_traces) do %>
            <ul>
              <%= for trace <- @unlocked_traces do %>
                <li id={"unlocked-trace:#{trace.id}"}>
                  <img src={trace.photo_url} alt={"ID:#{trace.id}'s trace photo"}>
                  <.button phx-click="connect" phx-value-trace-id={trace.id}>Connect</.button>
                </li>
              <% end %>
            </ul>
          <% end %>
        </section>
      <% end %>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    user = MissedU.Connections.load_profile(socket.assigns.current_user)

    {:ok,
      socket
      |> assign(:profile, user.profile)
      |> assign(:position, nil)
      |> assign(:key_form, nil)
      |> assign(:unlocked_traces, nil)}
  end

  def handle_event("location:updated-position", %{"latitude" => lat, "longitude" => lon}, socket) do
    nearby_count = Enum.count(MissedU.Connections.nearby_traces(lat, lon))

    {:noreply,
      socket
      |> put_flash(:info, "Updated position: (#{lat}, #{lon})")
      |> assign(:nearby_count, nearby_count)
      |> assign(:position, %{latitude: lat, longitude: lon})
      |> assign(:key_form, to_form(%{"value" => ""}, as: :unlock_key))}
  end

  def handle_event("unlock", %{"unlock_key" => %{"value" => key}}, socket) do
    %{latitude: lat, longitude: lon} = socket.assigns.position
    unlocked_nearby = MissedU.Connections.unlock_nearby(lat, lon, key)

    {:noreply, assign(socket, :unlocked_traces, unlocked_nearby)}
  end

  def handle_event("connect", %{"trace-id" => id}, socket) do
    # TODO: Fetch trace from db, preload author, send connect request
    IO.inspect(id, label: "connect")

    {:noreply, socket}
  end

  defp display_total_trace_count(count) when is_integer(count) do
    case count do
      0 -> "No one has left a trace"
      1 -> "1 person left a trace"
      n -> "#{n} people left traces"
    end
  end

  defp display_unlocked_trace_count(traces) when is_list(traces) do
    case Enum.count(traces) do
      1 -> "one trace"
      n -> "#{n} traces"
    end
  end

  defp to_float(term) when is_binary(term) do
    {float, _} = Float.parse(term)
    float
  end
end
