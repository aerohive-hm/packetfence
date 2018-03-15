<div id="tracker" class="row-fluid">
  <div class="span14 offset4">
        <ul class="nav nav-pills" style="vertical-align: center;">
        [% FOREACH step IN steps -%]
          [% IF step.id != "Database" && step.title != "Database" %]
          <li[% IF step.id == c.action.name %] class="active"[% END %]>
            <a href="[% c.uri_for(step.id) %]" rel="tooltip" title="[% l(step.description) %]"><i>&#101[% loop.index + 22 %];</i> <span style="vertical-align: text-top;">[% l(step.title) %]</span></a>
          </li>
          [%- END -%]
        [%- END -%]
        </ul>
  </div>
</div>
