let chartData = null;

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
  const isResult = haveResult(payload)
  const result = isResult
    ? { home: payload.match.home_score, away: payload.match.away_score }
    : null;
  const l = predictions.length;

  const predictionSeriesByUserId = new Map();
  predictions.forEach(function(prediction, index) {
    predictionSeriesByUserId.set(String(prediction.user_id), index);
  });

  data.addColumn('number');
  predictions.forEach(function(prediction) {
    data.addColumn('number', prediction.name);
  });
  if (isResult) {
    data.addColumn('number', 'Result');
  }
  data.addColumn('number', 'Win Line');
  data.addColumn({ type: 'string', role: 'tooltip' });

  let maxScore = 0;
  predictions.forEach(function(prediction, index) {
    data.addRow();
    data.setCell(index, 0, prediction.home);
    data.setCell(index, index + 1, prediction.away);
    if (isResult) {
      data.setCell(index, l + 3, prediction.name);
    } else {
      data.setCell(index, l + 2, prediction.name);
    }
    maxScore = (prediction.home > maxScore) ? prediction.home : maxScore;
    maxScore = (prediction.away > maxScore) ? prediction.away : maxScore;
  });

  if (isResult) {
    data.addRow();
    data.setCell(l, 0, result.home);
    data.setCell(l, l + 1, result.away);
    data.setCell(l, l + 3, 'Result');

    maxScore = (result.home > maxScore) ? result.home : maxScore;
    maxScore = (result.away > maxScore) ? result.away : maxScore;
  }
  const maxScale = roundUpToFive(maxScore);

  const winOffset = isResult ? l + 1 : l;
  data.addRow();
  data.setCell(winOffset, 0, 0);
  data.setCell(winOffset, winOffset + 1, 0);
  data.setCell(winOffset, winOffset + 2, '');
  data.addRow();
  data.setCell(winOffset + 1, 0, maxScale);
  data.setCell(winOffset + 1, winOffset + 1, maxScale);
  data.setCell(winOffset + 1, winOffset + 2, '');

  chartData = {
    data: data,
    homeName: payload.match.home_name,
    awayName: payload.match.away_name,
    haveResult: isResult,
    maxScale: maxScale,
    seriesLookup: predictionSeriesByUserId
  };
}

function getSeries() {
  let series = [];
  let max = 0;
  document.querySelectorAll('#collapseUsers [type=checkbox]').forEach(function(checkbox) {
    const index = chartData.seriesLookup.get(checkbox.value);
    max = (index > max) ? index : max;
    if (checkbox.checked) {
      series[index] = { visibleInLegend: true, pointSize: 6 };
    } else {
      series[index] = { color: '#888', visibleInLegend: false, pointSize: 2 };
    }
  });

  if (chartData.haveResult) {
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

function drawChart() {
  if (!chartData) {
    return;
  }
  const scale = chartData.maxScale;

  const container = document.getElementById('chartMatch');
  const w = container.offsetWidth;
  const h = w;

  const options = {
    height: h,
    width: w,
    lineWidth: 0,
    pointSize: 4,
    legend: { position: 'top' },
    hAxis: {
      title: chartData.homeName,
      textPosition: 'out',
      baselineColor: 'transparent',
      gridlines: { color: '#f4f4f4', interval: [1, 5] },
      minorGridlines: { count: 0 },
      format: '#',
      maxValue: scale,
      minValue: 0
    },
    vAxis: {
      title: chartData.awayName,
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

  const chart = new google.visualization.LineChart(document.getElementById('chartMatch'));
  chart.draw(chartData.data, options);
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
      buildMatchGraphData(payload);
      drawChart();
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
      drawChart();
    }, 500);
  });

  const usersPanel = document.querySelector('#collapseUsers');
  if (usersPanel) {
    usersPanel.querySelectorAll('[type=checkbox]').forEach(function(checkbox) {
      checkbox.addEventListener('click', function() {
        drawChart();
      });
    });
  }
}

document.addEventListener('DOMContentLoaded', function() {
  addMatchGraphListeners();
  google.charts.load('current', { packages: ['corechart'] });
  google.charts.setOnLoadCallback(loadMatchGraphData);
});
