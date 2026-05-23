let matchGraphPayload = null;

function getMatchGraphUrl() {
  const root = document.getElementById('chartMatch');
  return root ? root.dataset.predictionsUrl : null;
}

function roundUpToFive(value) {
  return (Math.floor((value - 1) / 5) + 1) * 5;
}

function haveResult(payload) {
  return payload && payload.match &&
         payload.match.home_score !== null &&
         payload.match.home_score !== undefined &&
         payload.match.away_score !== null &&
         payload.match.away_score !== undefined
}

function buildMatchGraphData(payload) {
  let data = new google.visualization.DataTable();
  const predictions = payload.predictions || [];
  const result = haveResult(payload)
    ? { home: payload.match.home_score, away: payload.match.away_score }
    : null;
  const l = predictions.length;

  data.addColumn('number');
  predictions.forEach(function(prediction) {
    data.addColumn('number', prediction.name);
  });
  if (result) {
    data.addColumn('number', 'Result');
  }
  data.addColumn('number', 'Win Line');
  data.addColumn({ type: 'string', role: 'tooltip' });

  let maxScore = 0;
  predictions.forEach(function(prediction, index) {
    data.addRow();
    data.setCell(index, 0, prediction.home);
    data.setCell(index, index + 1, prediction.away);
    if (result) {
      data.setCell(index, l + 3, prediction.name);
    } else {
      data.setCell(index, l + 2, prediction.name);
    }
    maxScore = (prediction.home > maxScore) ? prediction.home : maxScore;
    maxScore = (prediction.away > maxScore) ? prediction.away : maxScore;
  });

  if (result) {
    maxScore = (result.home > maxScore) ? result.home : maxScore;
    maxScore = (result.away > maxScore) ? result.away : maxScore;
  }

  maxScore = roundUpToFive(maxScore);

  if (result) {
    data.addRow();
    data.setCell(l, 0, result.home);
    data.setCell(l, l + 1, result.away);
    data.setCell(l, l + 3, 'Result');
  }

  data.addRow();
  if (result) {
    data.setCell(l + 1, 0, 0);
    data.setCell(l + 1, l + 2, 0);
    data.setCell(l + 1, l + 3, '');
    data.addRow();
    data.setCell(l + 2, 0, maxScore);
    data.setCell(l + 2, l + 2, maxScore);
    data.setCell(l + 2, l + 3, '');
  } else {
    data.setCell(l, 0, 0);
    data.setCell(l, l + 1, 0);
    data.setCell(l, l + 2, '');
    data.addRow();
    data.setCell(l + 1, 0, maxScore);
    data.setCell(l + 1, l + 1, maxScore);
    data.setCell(l + 1, l + 2, '');
  }

  return { data: data, maxScale: maxScore };
}

function getSeries() {
  let series = [];
  let max = 0;
  document.querySelectorAll('#collapseUsers [type=checkbox]').forEach(function(checkbox) {
    const index = Number(checkbox.value) - 1;
    max = (index > max) ? index : max;
    if (checkbox.checked) {
      series[index] = { visibleInLegend: true, pointSize: 6 };
    } else {
      series[index] = { color: '#888', visibleInLegend: false, pointSize: 2 };
    }
  });

  if (haveResult(matchGraphPayload)) {
    series[max + 1] = {
      color: '#bd162d',
      visibleInLegend: true,
      pointSize: 20,
      pointShape: { type: 'star', sides: 4, rotation: 45, dent: 0.2 }
    };
    series[max + 2] = { color: '#dddddd', visibleInLegend: false, pointSize: 0, lineWidth: 2 };
  } else {
    series[max + 1] = { color: '#dddddd', visibleInLegend: false, pointSize: 0, lineWidth: 2 };
  }

  return series;
}

function drawChart(dataTable, scale, id) {
  let h = window.innerHeight;
  let w = window.innerWidth;

  w = Math.min(w, 700);
  h -= 90;
  w -= 30;
  if (h > w) {
    h = w;
  } else {
    w = h;
  }

  const options = {
    height: h,
    width: w,
    lineWidth: 0,
    pointSize: 4,
    legend: { position: 'top' },
    hAxis: {
      title: matchGraphPayload.match.home_name,
      textPosition: 'out',
      baselineColor: 'transparent',
      gridlines: { color: '#f4f4f4', interval: [1, 5] },
      minorGridlines: { count: 0 },
      format: '#',
      maxValue: scale,
      minValue: 0
    },
    vAxis: {
      title: matchGraphPayload.match.away_name,
      textPosition: 'out',
      baselineColor: 'transparent',
      gridlines: { color: '#f4f4f4', interval: [1, 5] },
      minorGridlines: { count: 0 },
      format: '#',
      maxValue: scale,
      minValue: 0
    },
    crosshair: { trigger: 'both', orientation: 'both' },
    series: getSeries()
  };

  const chart = new google.visualization.LineChart(document.getElementById(id));
  chart.draw(dataTable, options);
}

function draw() {
  if (!matchGraphPayload) {
    return;
  }
  const chartData = buildMatchGraphData(matchGraphPayload);
  drawChart(chartData.data, chartData.maxScale, 'chartMatch');
}

function loadMatchGraphData() {
  const url = getMatchGraphUrl();
  if (!url) {
    return;
  }

  fetch(url, { headers: { Accept: 'application/json' } })
    .then(function(response) {
      if (!response.ok) {
        showAlertMessage('Failed to load match graph data', 'danger');
      }
      return response.json();
    })
    .then(function(payload) {
      matchGraphPayload = payload;
      draw();
    })
    .catch(function(error) {
      showAlertMessage(error, 'danger');
    });
}

function addMatchGraphListeners() {
  let resizeTimer = null;
  window.addEventListener('resize', function() {
    if (resizeTimer) {
      clearTimeout(resizeTimer);
    }
    resizeTimer = setTimeout(function() {
      draw();
    }, 500);
  });

  const usersPanel = document.querySelector('#collapseUsers');
  if (usersPanel) {
    usersPanel.querySelectorAll('[type=checkbox]').forEach(function(checkbox) {
      checkbox.addEventListener('click', function() {
        draw();
      });
    });
  }
}

document.addEventListener('DOMContentLoaded', function() {
  addMatchGraphListeners();
  google.charts.load('current', { packages: ['corechart'] });
  google.charts.setOnLoadCallback(loadMatchGraphData);
});
