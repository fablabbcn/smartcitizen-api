class Breadcrumb < Struct.new(:breadcrumbs, :label, :url)
  def active?
    self == breadcrumbs.last
  end
end

