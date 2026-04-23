using System;
using System.Collections.Generic;
using DramaMurderGraduation.Web.Data;
using DramaMurderGraduation.Web.Models;

namespace DramaMurderGraduation.Web
{
    public partial class SpectatorPage : System.Web.UI.Page
    {
        private readonly FeatureRepository _repository = new FeatureRepository();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack)
            {
                return;
            }

            BindPage();
        }

        private void BindPage()
        {
            var modes = _repository.GetSpectatorModes();
            var rooms = _repository.GetSpectatorRooms();
            var selectedRoom = ResolveSelectedRoom(rooms);
            var messages = selectedRoom != null
                ? _repository.GetSpectatorMessages(selectedRoom.Id, 8)
                : new List<SpectatorMessageInfo>();

            rptSpectatorModes.DataSource = modes;
            rptSpectatorModes.DataBind();

            rptSpectatorRooms.DataSource = rooms;
            rptSpectatorRooms.DataBind();

            rptSpectatorMessages.DataSource = messages;
            rptSpectatorMessages.DataBind();

            if (selectedRoom == null)
            {
                imgSelectedCover.ImageUrl = "https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80";
                litRoomStatus.Text = "暂无房间";
                litSelectedRoomTitle.Text = "当前没有可观战房间";
                litSelectedRoomScript.Text = "当前还没有开放中的观战房间，晚些时候再来看看热局。";
                litSelectedHost.Text = "-";
                litSelectedRouteCode.Text = "-";
                litSelectedViewerCount.Text = "0 人观看";
                litSelectedHeatScore.Text = "0";
                return;
            }

            imgSelectedCover.ImageUrl = selectedRoom.CoverImage;
            litRoomStatus.Text = selectedRoom.RoomStatus;
            litSelectedRoomTitle.Text = selectedRoom.Title;
            litSelectedRoomScript.Text = selectedRoom.ScriptName;
            litSelectedHost.Text = selectedRoom.HostName;
            litSelectedRouteCode.Text = selectedRoom.RouteCode;
            litSelectedViewerCount.Text = selectedRoom.ViewerCount + " 人观看";
            litSelectedHeatScore.Text = selectedRoom.HeatScore.ToString();
        }

        private SpectatorRoomInfo ResolveSelectedRoom(IList<SpectatorRoomInfo> rooms)
        {
            if (rooms == null || rooms.Count == 0)
            {
                return null;
            }

            if (int.TryParse(Request.QueryString["roomId"], out var roomId))
            {
                foreach (var room in rooms)
                {
                    if (room.Id == roomId)
                    {
                        return room;
                    }
                }
            }

            return rooms[0];
        }
    }
}
