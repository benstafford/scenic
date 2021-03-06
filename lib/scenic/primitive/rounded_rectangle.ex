#
#  Created by Boyd Multerer on 5/8/17.
#  Copyright © 2017 Kry10 Industries. All rights reserved.
#

defmodule Scenic.Primitive.RoundedRectangle do
  @moduledoc false

  use Scenic.Primitive

  # import IEx

  @styles [:hidden, :fill, :stroke]

  # ============================================================================
  # data verification and serialization

  # --------------------------------------------------------
  def info(data),
    do: """
      #{IO.ANSI.red()}#{__MODULE__} data must be: {width, height, radius}
      #{IO.ANSI.yellow()}Received: #{inspect(data)}
      "Radius will be clamped to half of the smaller of width or height."
      #{IO.ANSI.default_color()}
    """

  # --------------------------------------------------------
  def verify(data) do
    normalize(data)
    {:ok, data}
  rescue
    _ -> :invalid_data
  end

  # --------------------------------------------------------
  def normalize({width, height, radius})
      when is_number(width) and is_number(height) and is_number(radius) and radius >= 0 do
    w = abs(width)
    h = abs(height)

    # clamp the radius
    radius =
      case w <= h do
        # width is smaller
        true -> min(radius, w / 2)
        # height is smaller
        false -> min(radius, h / 2)
      end

    {width, height, radius}
  end

  # ============================================================================
  @spec valid_styles() :: [:fill | :hidden | :stroke, ...]
  def valid_styles(), do: @styles

  # --------------------------------------------------------
  def default_pin(data), do: centroid(data)

  # --------------------------------------------------------
  def centroid(data)

  def centroid({width, height, _}) do
    {width / 2, height / 2}
  end

  # --------------------------------------------------------
  def contains_point?({w, h, r}, {xp, yp}) do
    # point in a rounded rectangle is the same problem as "is point within radius of the interior rectangle"
    # note also that point is in local space for primitive (presumably centered on the centroid)

    # so, somebody on SO solved a variant of the problem, so we'll adapt their work:
    # https://gamedev.stackexchange.com/a/44496

    # judging from the tests, it seems like the rectangle is meant to be tested in quadrant 1
    # and not centered about the origin as I'd originally thought

    if w * xp >= 0 and h * yp >= 0 do
      # since the sign of both x and y are the same, we do our math in abs land
      # spotted this trick from the rectangle code
      aw = abs(w)
      ah = abs(h)
      ax = abs(xp)
      ay = abs(yp)

      # get the dimensions and center of the "inner rectangle"
      # e.g., the one without the radii at the corners
      rw = aw - 2 * r
      rh = ah - 2 * r
      rx = r + rw / 2
      ry = r + rh / 2

      # calculate the distance of the point to the rectangle
      dx = max(abs(ax - rx) - rw / 2, 0)
      dy = max(abs(ay - ry) - rh / 2, 0)
      dx * dx + dy * dy <= r * r
    else
      false
    end
  end
end
