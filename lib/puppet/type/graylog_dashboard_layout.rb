Puppet::Type.newtype(:graylog_dashboard_layout) do

  desc <<-END_OF_DOC
    @summary
      Lays out the widgets on a dashboard.
      
    @see graylog_dashboard
    @see graylog_dashboard_widget

    @example
      graylog_dashboard_layout { 'Example Dashboard':
        positions => {
          'Example Widget 1' => {x => 1, y => 1, w => 2, h => 5},
          'Example Widget 2' => {x => 3, y => 1, w => 2, h => 5},
          'Example Widget 3' => {x => 1, y => 6, w => 4, h => 2},
        },
      }
  END_OF_DOC

  newparam(:name) do
    desc 'The name of the Dashboard whose layout this is.'
  end

  newproperty(:positions) do
    desc <<-END_OF_PROPERTY
      A hash of hashes. Each key is the name of a widget appearing on this
      dashboard. The corresponding value is a hash with four keys:
        * x - The horizontal position of this widget
        * y - The vertical position of this widget
        * w - The width of this widget
        * h - The height of this widget
    END_OF_PROPERTY
    validate do |all_widgets|
      all_widgets.each_pair do |key,value|
        raise ArgumentError, "Widget #{key} must have a x-position," unless value.has_key?('x')
        raise Argumenterror, "Widget #{key} must have a y-position." unless value.has_key?('y')
        raise ArgumentError, "Widget #{key} must have a width." unless value.has_key?('w')
        raise ArgumentError, "Widget #{key} must have a height." unless value.has_key?('h')
      end
    end
  end

  autorequire('file') { 'graylog_api_config.yaml' }
  autorequire('graylog_dashboard') { self[:name] }
  autorequire('graylog_dashboard_widget') { self[:positions].keys.map {|widget_name| "#{self[:name]}!!!#{widget_name}" } }
end
