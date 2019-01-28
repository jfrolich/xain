defmodule Xain.Helpers do
  require Logger

  def ensure_valid_contents(contents, _) when is_binary(contents) or is_list(contents) do
    contents
  end
  def ensure_valid_contents(contents, tag_name) do
    Logger.debug "#{tag_name} has been called as #{tag_name}(#{inspect(contents)}, ...), but the first argument supposed to be a binary"
    to_string(contents)
  end

  def id_and_class_shortcuts(contents, attrs) when is_binary(contents) do
    tokenize(contents) |> _id_and_class_shortcuts(attrs)
  end
  def id_and_class_shortcuts(attrs, _) when is_list(attrs), do: {"", attrs}

  defp _id_and_class_shortcuts([], attrs), do: {"", attrs}

  @class_id_regex ~r/^[a-zA-Z\-_0-9]+[ ]?$/
  defp _id_and_class_shortcuts([h | t], attrs) do
    case h do
      contents = "#" <> id ->
        if Regex.match?(@class_id_regex, id) do
          id = String.trim(id)
          _id_and_class_shortcuts(t, merge_id_or_class(:id, id, attrs))
        else
          {contents, attrs}
        end

      contents = "." <> class ->
        if Regex.match?(@class_id_regex, class) do
          class = String.trim(class)
          _id_and_class_shortcuts(t, merge_id_or_class(:class, class, attrs))
        else
          IO.inspect(class)
          {contents, attrs}
        end

      # "%" <> name ->
      #   name = String.strip(name)
      #   _id_and_class_shortcuts(t, struct(tag, name: String.to_atom(name)))

      contents ->
        {contents, attrs}
    end
  end

  defp merge_id_or_class(:id, item, attrs ) do
    Keyword.merge([id: item], attrs)
  end

  defp merge_id_or_class(:class, item, attrs) do
    case Keyword.get(attrs, :class, "") do
      "" ->
        Keyword.put(attrs, :class, item)
      other ->
        Keyword.put(attrs, :class, other <> " " <> item)
    end
  end

  @tag_class_id ~S/(^%|[.#])[-:\w]+/
  @rest         ~S/(.+)/

  @regex        ~r/(?:#{@tag_class_id}|#{@rest})\s*/s


  defp tokenize(string) do
    Regex.scan(@regex, string, trim: true) |> reduce
  end

  defp reduce([]), do: []
  defp reduce([h|t]) do
    [List.foldr(h, "", fn(x, _acc) -> x end) | reduce(t)]
  end
end
