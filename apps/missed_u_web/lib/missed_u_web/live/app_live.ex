defmodule MissedUWeb.AppLive do
  use MissedUWeb, :live_view

  alias MissedU.Connections.Trace

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
            <.link_button phx-click={show_modal("trace-form-modal")}>Leave a trace</.link_button>
          </p>

          <.simple_form for={@key_form} phx-submit="unlock">
            <.input field={@key_form[:value]} label="Key"/>
            <:actions>
              <.button>Unlock Traces</.button>
            </:actions>
          </.simple_form>

          <.trace_list traces={@unlocked_traces} />
        </section>
      <% end %>
    </div>

    <.modal id="trace-form-modal" on_cancel={JS.dispatch("reset-fields", to: "#trace-form")}>
      <h1 class="text-4xl font-black">Leave a trace</h1>

      <.simple_form
        id="trace-form"
        for={@trace_form}
        phx-submit="leave-trace"
        phx-hook="FormManager"
        data-after-submit={hide_modal("trace-form-modal")}
      >
        <.input field={@trace_form[:key]} label="Key"/>
        <.input field={@trace_form[:photo_url]} label="Photo URL"/>
        <input type="reset" class="hidden">

        <:actions>
          <.button>Leave Trace</.button>
        </:actions>
      </.simple_form>
    </.modal>
    """
  end

  attr :traces, :list, default: [], doc: "list of traces"

  def trace_list(assigns) do
    ~H"""
    <%= if Enum.count(@traces) > 0 do %>
      <ul>
        <%= for trace <- @traces do %>
          <.trace_list_item trace={trace} />
        <% end %>
      </ul>
    <% end %>
    """
  end

  attr :trace, :map, required: true, doc: "the trace"

  def trace_list_item(assigns) do
    ~H"""
    <li id={"unlocked-trace:#{@trace.id}"}>
      <img src={@trace.photo_url} alt={"ID:#{@trace.id}'s trace photo"}>
      <.button phx-click="connect" phx-value-trace-id={@trace.id}>Connect</.button>
    </li>
    """
  end

  attr :rest, :global, include: ~w(disabled form name value)
  slot :inner_block, required: true

  def link_button(assigns) do
    ~H"""
    <button class="underline" {@rest}>
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  def mount(_params, _session, socket) do
    {:ok,
      socket
      |> assign(:position, nil)
      |> assign(:unlocked_traces, [])
      |> assign(:trace_form, trace_form())
      |> assign(:key_form, unlock_key_form())
      |> assign(:profile, MissedU.Connections.load_profile(socket.assigns.current_user))}
  end

  def handle_event("location:updated-position", %{"latitude" => lat, "longitude" => lon}, socket) do
    nearby_count = Enum.count(MissedU.Connections.nearby_traces(lat, lon))

    {:noreply,
      socket
      |> put_flash(:info, "Updated position: (#{lat}, #{lon})")
      |> assign(:nearby_count, nearby_count)
      |> assign(:position, %{latitude: lat, longitude: lon})
      |> assign(:key_form, unlock_key_form())}
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

  def handle_event("leave-trace", %{"trace" => trace_params}, socket) do
    %{latitude: lat, longitude: lon} = socket.assigns.position

    trace_params =
      trace_params
      |> Map.put("latitude", lat)
      |> Map.put("longitude", lon)
      |> Map.put("author_profile", socket.assigns.profile)

    %MissedU.Connections.Trace{} = MissedU.Connections.create_trace(trace_params)

    {:noreply, push_event(socket, "after-submit", %{id: "trace-form"})}
  end

  defp unlock_key_form do
    to_form(%{"value" => ""}, as: :unlock_key)
  end

  defp trace_form do
    to_form(Trace.changeset(%Trace{}, %{}), as: :trace)
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
end
