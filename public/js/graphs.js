let graphsPayload = null;

function getGraphsUrl() {
  const root = document.getElementById('graphsApp');
  return root ? root.dataset.graphsUrl : '/graphs/data';
}

function loadGraphsData() {
  fetch(getGraphsUrl(), { headers: { Accept: 'application/json' } })
    .then(function(response) {
      if (!response.ok) {
        throw new Error('Failed to load graph data');
      }
      return response.json();
    })
    .then(function(payload) {
      graphsPayload = payload.points || [];
      drawCharts();
    })
    .catch(function(error) {
      console.error(error);
    });
}

function getSeries() {
  const series = [];
  const checkboxes = document.querySelectorAll('#collapseUsers [type=checkbox]');

  checkboxes.forEach(function(checkbox, index) {
    if (checkbox.checked) {
      series[index] = { visibleInLegend: true, pointSize: 3, lineWidth: 3 };
    } else {
      series[index] = { color: '#dddddd', visibleInLegend: false, pointSize: 0, lineWidth: 1 };
    }
  });

  return series;
}

function buildPointsData(kind) {
  const data = new google.visualization.DataTable();
  if (!graphsPayload || graphsPayload.length === 0) {
    return data;
  }

  let users = graphsPayload[0].users || [];
  data.addColumn('string', 'Match');
  users.forEach(function(user) {
    data.addColumn('number', user.user_name);
  });

  graphsPayload.forEach(function(match) {
    const row = [match.match];
    users.forEach(function(user) {
      const matchUser = match.users.find(function(candidate) {
        return candidate.user_id === user.user_id;
      });
      row.push(matchUser ? matchUser[kind] : null);
    });
    data.addRow(row);
  });

  return data;
}

function drawChart(dataTable, id, rev) {
  const container = document.getElementById('graphsApp');
  const w = container.offsetWidth;
  const h = w / 9 * 5;

  const options = {
    chartArea: { width: '100%', height: '100%' },
    height: h,
    width: w,
    legend: { position: 'in' },
    hAxis: { textPosition: 'none', baselineColor: 'transparent', gridlines: { color: 'transparent' } },
    vAxis: { textPosition: 'none', baselineColor: 'transparent', gridlines: { color: 'transparent' } },
    series: getSeries()
  };

  if (rev) {
    options.vAxis.direction = -1;
  }

  const chart = new google.visualization.LineChart(document.getElementById(id));
  chart.draw(dataTable, options);
}

function drawCharts() {
  if (!graphsPayload) {
    return;
  }
  drawChart(buildPointsData('cum_points'), 'chartOverall', false);
  drawChart(buildPointsData('rel_points'), 'chartRelative', false);
  drawChart(buildPointsData('rank'), 'chartPosition', true);
}

function addGraphsListeners() {
  const usersPanel = document.querySelector('#collapseUsers');
  if (usersPanel) {
    usersPanel.querySelectorAll('[type=checkbox]').forEach(function(checkbox) {
      checkbox.addEventListener('click', function() {
        drawCharts();
      });
    });
  }

  let resizeTimer = null;
  window.addEventListener('resize', function() {
    if (resizeTimer) {
      clearTimeout(resizeTimer);
    }
    resizeTimer = setTimeout(function() {
      drawCharts();
    }, 500);
  });
}

document.addEventListener('DOMContentLoaded', function() {
  addGraphsListeners();
  google.charts.load('current', { packages: ['corechart'] });
  google.charts.setOnLoadCallback(loadGraphsData);
});
