defmodule MissedUWeb.TraceLive do
  use MissedUWeb, :live_view

  alias MissedU.Connections.Trace

  def render(assigns) do
    ~H"""
    <h1 class="text-4xl font-black">Create Trace</h1>

    <.simple_form for={@form} phx-submit="submit">
      <.input field={@form[:key]} label="Key"/>
      <.input field={@form[:photo_url]} label="Photo URL"/>
      <.input type="hidden" field={@form[:latitude]} value={@position.latitude}/>
      <.input type="hidden" field={@form[:longitude]} value={@position.longitude}/>

      <:actions>
        <.button>Submit Traces</.button>
      </:actions>
    </.simple_form>
    """
  end

  def mount(%{"latitude" => lat, "longitude" => lon}, _session, socket) do
    user = MissedU.Connections.load_profile(socket.assigns.current_user)

    {:ok,
      socket
      |> assign(:form, trace_form())
      |> assign(:profile, user.profile)
      |> assign(:position, %{latitude: lat, longitude: lon})}
  end

  def handle_event("submit", %{"trace" => trace_params}, socket) do
    {latitude, _} = Float.parse(trace_params["latitude"])
    {longitude, _} = Float.parse(trace_params["longitude"])

    trace_params =
      trace_params
      |> Map.put("latitude", latitude)
      |> Map.put("longitude", longitude)
      |> Map.put("author_profile", socket.assigns.profile)

    %MissedU.Connections.Trace{} = MissedU.Connections.create_trace(trace_params)

    {:noreply, Phoenix.LiveView.redirect(socket, to: ~p"/app")}
  end

  defp trace_form do
    to_form(Trace.changeset(%Trace{}, %{}), as: :trace)
  end
end
